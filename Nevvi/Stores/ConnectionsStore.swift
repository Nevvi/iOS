//
//  ConnectionsStore.swift
//  Nevvi
//
//  Created by Tyler Cobb on 12/31/22.
//

import Foundation

class ConnectionsStore : ObservableObject {
    var authorization: Authorization? = nil
    
    @Published var loading: Bool = false
    @Published var connections: [Connection] = []
    @Published var connectionCount: Int = 0
    
    @Published var loadingRequests: Bool = false
    @Published var requests: [ConnectionRequest] = []
    @Published var requestCount: Int = 0
    
    
    private func url() throws -> URL {
        if (self.authorization == nil) {
            throw GenericError("Not logged in")
        }
        
        let userId: String? = self.authorization?.id
        return URL(string: "https://api.development.nevvi.net/user/v1/users/\(userId!)/connections")!
    }
    
    private func requestsUrl() throws -> URL {
        if (self.authorization == nil) {
            throw GenericError("Not logged in")
        }
        
        let userId: String? = self.authorization?.id
        return URL(string: "https://api.development.nevvi.net/user/v1/users/\(userId!)/connections/requests/pending")!
    }
    
    func load() {
        do {
            self.loading = true
            let idToken: String? = self.authorization?.idToken
            URLSession.shared.fetchData(for: try self.url(), for: "Bearer \(idToken!)") { (result: Result<ConnectionResponse, Error>) in
                switch result {
                case .success(let response):
                    self.connections = response.users
                    self.connectionCount = response.count
                case .failure(let error):
                    print(error)
                }
                self.loading = false
            }
        } catch(let error) {
            print("Failed to load connections", error)
        }
    }
    
    func loadRequests() {
        do {
            self.loadingRequests = true
            let idToken: String? = self.authorization?.idToken
            URLSession.shared.fetchData(for: try self.requestsUrl(), for: "Bearer \(idToken!)") { (result: Result<[ConnectionRequest], Error>) in
                switch result {
                case .success(let requests):
                    self.requests = requests
                case .failure(let error):
                    print(error)
                }
                self.loadingRequests = false
            }
        } catch(let error) {
            print("Failed to load connections", error)
        }
    }
}
