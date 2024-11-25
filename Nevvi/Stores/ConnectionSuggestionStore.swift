//
//  ConnectionSuggestionStore.swift
//  Nevvi
//
//  Created by Tyler Standal on 1/28/24.
//

import Foundation

class ConnectionSuggestionStore : ObservableObject {
    var authorization: Authorization? = nil
    
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
        
        let userId: String? = self.authorization?.id
        return URL(string: "\(BuildConfiguration.shared.baseURL)/user/v1/users/\(userId!)/suggestions")!
    }
    
    private func ignoreSuggestionUrl(suggestionId: String) throws -> URL {
        if (self.authorization == nil) {
            throw GenericError("Not logged in")
        }
        
        let userId: String? = self.authorization?.id
        return URL(string: "\(BuildConfiguration.shared.baseURL)/user/v1/users/\(userId!)/suggestions/\(suggestionId)")!
    }

    func loadSuggestions() {
        do {
            self.loading = true
            let idToken: String? = self.authorization?.idToken

            URLSession.shared.fetchData(for: try getSuggestionsUrl(), for: "Bearer \(idToken!)") { (result: Result<[Connection], Error>) in
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
            self.loading = true
            let idToken: String? = self.authorization?.idToken
            URLSession.shared.deleteData(for: try ignoreSuggestionUrl(suggestionId: suggestionId), for: "Bearer \(idToken!)") { (result: Result<IgnoreSuggestionResponse, Error>) in
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
