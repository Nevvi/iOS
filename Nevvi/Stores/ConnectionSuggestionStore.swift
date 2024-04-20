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
    
    private func url() throws -> URL {
        if (self.authorization == nil) {
            throw GenericError("Not logged in")
        }
        
        let userId: String? = self.authorization?.id
        return URL(string: "\(BuildConfiguration.shared.baseURL)/user/v1/users/\(userId!)/connections/suggested")!
    }

    func loadSuggestions() {
        do {
            self.search(url: try self.url())
        } catch(let error) {
            self.error = GenericError(error.localizedDescription)
            self.loading = false
        }
    }
    
    private func search(url: URL) {
        self.loading = true
        let idToken: String? = self.authorization?.idToken
        URLSession.shared.fetchData(for: url, for: "Bearer \(idToken!)") { (result: Result<[Connection], Error>) in
            switch result {
            case .success(let response):
                self.users = response
                self.userCount = response.count
            case .failure(let error):
                self.error = GenericError(error.localizedDescription)
            }
            self.loading = false
        }
    }
    
    func removeUser(user: Connection) {
        self.users = self.users.filter { $0 != user }
        
        // TODO - Need to be smarter about this
        self.userCount = self.userCount - 1
    }
}
