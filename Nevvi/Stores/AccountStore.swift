//
//  AccountStore.swift
//  Nevvi
//
//  Created by Tyler Cobb on 12/29/22.
//

import Foundation

class AccountStore: ObservableObject {
    var authorization: Authorization? = nil
    @Published var user: User? = nil
    
    private func url() throws -> URL {
        if (self.authorization == nil) {
            throw GenericError("Not logged in")
        }
        
        let userId: String? = self.authorization?.id
        return URL(string: "https://api.development.nevvi.net/user/v1/users/\(userId!)")!
    }
    
    func load() {
        do {
            let idToken: String? = self.authorization?.idToken
            URLSession.shared.fetchData(for: try self.url(), for: "Bearer \(idToken!)") { (result: Result<User, Error>) in
                switch result {
                case .success(let user):
                    self.user = user
                case .failure(let error):
                    print(error)
                }
            }
        } catch(let error) {
            print("Failed to load user", error)
        }
    }
}
