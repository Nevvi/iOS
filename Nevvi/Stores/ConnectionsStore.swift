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
    
    @Published var deletingRequest: Bool = false
    @Published var loadingRequests: Bool = false
    @Published var requests: [ConnectionRequest] = []
    @Published var requestCount: Int = 0
    
    init() {
        
    }
    
    init(connections: [Connection], requests: [ConnectionRequest]) {
        self.connections = connections
        self.connectionCount = connections.count
        
        self.requests = requests
        self.requestCount = requests.count
    }
    
    private func url(nameFilter: String?) throws -> URL {
        if (self.authorization == nil) {
            throw GenericError("Not logged in")
        }
        
        let userId: String? = self.authorization?.id
        var urlString = "https://api.development.nevvi.net/user/v1/users/\(userId!)/connections"
        
        if nameFilter != nil && nameFilter!.count >= 3 {
            urlString = "\(urlString)?name=\(nameFilter!)"
        }
        
        return URL(string: urlString)!
    }
    
    private func requestsUrl() throws -> URL {
        if (self.authorization == nil) {
            throw GenericError("Not logged in")
        }
        
        let userId: String? = self.authorization?.id
        return URL(string: "https://api.development.nevvi.net/user/v1/users/\(userId!)/connections/requests/pending")!
    }
    
    private func deleteRequestUrl() throws -> URL {
        if (self.authorization == nil) {
            throw GenericError("Not logged in")
        }
        
        let userId: String? = self.authorization?.id
        return URL(string: "https://api.development.nevvi.net/user/v1/users/\(userId!)/connections/requests/deny")!
    }
    
    func load() {
        self.load(nameFilter: nil)
    }
    
    func load(nameFilter: String?) {
        do {
            self.loading = true
            let idToken: String? = self.authorization?.idToken
            URLSession.shared.fetchData(for: try self.url(nameFilter: nameFilter), for: "Bearer \(idToken!)") { (result: Result<ConnectionResponse, Error>) in
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
    
    func denyRequest(otherUserId: String, callback: @escaping (Result<Bool, Error>) -> Void) {
        do {
            self.deletingRequest = true
            let idToken: String? = self.authorization?.idToken
            let request = DenyRequest(otherUserId: otherUserId)
            URLSession.shared.postData(for: try self.deleteRequestUrl(), for: request, for: "Bearer \(idToken!)") { (result: Result<DeleteResponse, Error>) in
                switch result {
                case .success(_):
                    callback(.success(true))
                case .failure(let error):
                    callback(.failure(error))
                }
                self.deletingRequest = false
            }
        } catch(let error) {
            print("Failed to delete connection request", error)
        }
    }
    
    struct DenyRequest : Encodable {
        var otherUserId: String
    }
    
    struct DeleteResponse : Decodable {
        
    }
}