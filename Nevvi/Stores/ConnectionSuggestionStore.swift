//
//  ConnectionSuggestionStore.swift
//  Nevvi
//
//  Created by Tyler Standal on 1/28/24.
//

import Foundation

class ConnectionSuggestionStore : ObservableObject {
    @Published var authorization: Authorization? = nil {
        didSet {
            // Reset all state when authorization changes to prevent stale data issues
            if authorization == nil {
                // Reset loading states
                loading = false
                error = nil
                
                // Clear all data
                users = []
                userCount = 0
            } else if oldValue == nil && authorization != nil {
                // Authorization was set for the first time (login), load initial data
                DispatchQueue.main.async {
                    self.loadSuggestions()
                }
            }
        }
    }
    
    @Published var loading: Bool = false
    @Published var users: [Connection] = []
    @Published var userCount: Int = 0
    
    @Published var error: Swift.Error?
        
    init() {
        
    }
    
    init(users: [Connection]) {
        self.users = users
        self.userCount = users.count
    }
    
    private func getSuggestionsUrl() throws -> URL {
        if (self.authorization == nil) {
            throw GenericError("Not logged in")
        }
        
        let userId: String = self.authorization!.id
        return URL(string: "\(BuildConfiguration.shared.baseURL)/user/v1/users/\(userId)/suggestions")!
    }
    
    private func ignoreSuggestionUrl(suggestionId: String) throws -> URL {
        if (self.authorization == nil) {
            throw GenericError("Not logged in")
        }
        
        let userId: String = self.authorization!.id
        return URL(string: "\(BuildConfiguration.shared.baseURL)/user/v1/users/\(userId)/suggestions/\(suggestionId)")!
    }

    func loadSuggestions() {
        do {
            guard let authorization = self.authorization else {
                let error = GenericError("Not logged in")
                self.error = error
                self.loading = false
                return
            }
            
            self.loading = true

            URLSession.shared.fetchData(for: try getSuggestionsUrl(), with: authorization) { (result: Result<[Connection], Error>) in
                switch result {
                case .success(let response):
                    self.users = response
                    self.userCount = response.count
                case .failure(let error):
                    self.error = GenericError(error.localizedDescription)
                }
                self.loading = false
            }
        } catch(let error) {
            self.error = GenericError(error.localizedDescription)
            self.loading = false
        }
    }
    
    func ignoreSuggestion(suggestionId: String, callback: @escaping (Result<Bool, Error>) -> Void) {
        do {
            guard let authorization = self.authorization else {
                let error = GenericError("Not logged in")
                self.error = error
                callback(.failure(error))
                self.loading = false
                return
            }
            
            self.loading = true
            URLSession.shared.deleteData(for: try ignoreSuggestionUrl(suggestionId: suggestionId), with: authorization) { (result: Result<IgnoreSuggestionResponse, Error>) in
                switch result {
                case .success(let response):
                    self.users = self.users.filter { $0.id != suggestionId }
                    self.userCount = self.users.count
                    callback(.success(response.success))
                case .failure(let error):
                    self.error = GenericError(error.localizedDescription)
                    callback(.failure(error))
                }
                self.loading = false
            }
        } catch(let error) {
            self.error = GenericError(error.localizedDescription)
            self.loading = false
        }
    }
    
    struct IgnoreSuggestionResponse: Decodable {
        var success: Bool
    }
}
