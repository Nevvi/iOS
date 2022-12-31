//
//  ConnectionStore.swift
//  Nevvi
//
//  Created by Tyler Cobb on 12/31/22.
//

import Foundation

class ConnectionStore : ObservableObject {
    var authorization: Authorization? = nil
    
    @Published var connection: Connection? = nil
    @Published var loading: Bool = false
    
    init() {
        
    }
    
    init(connection: Connection) {
        self.connection = connection
    }
    
    private func url(connectionId: String) throws -> URL {
        if (self.authorization == nil) {
            throw GenericError("Not logged in")
        }
        
        let userId: String? = self.authorization?.id
        return URL(string: "https://api.development.nevvi.net/user/v1/users/\(userId!)/connections/\(connectionId)")!
    }
    
    func load(connectionId: String) {
        do {
            self.loading = true
            self.connection = nil
            let idToken: String? = self.authorization?.idToken
            URLSession.shared.fetchData(for: try self.url(connectionId: connectionId), for: "Bearer \(idToken!)") { (result: Result<Connection, Error>) in
                switch result {
                case .success(let connection):
                    self.connection = connection
                case .failure(let error):
                    print(error)
                }
                self.loading = false
            }
        } catch(let error) {
            print("Failed to load connection", error)
        }
    }
}
