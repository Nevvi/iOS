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
    
    @Published var outOfSyncCount: Int = 0
    
    @Published var confirmingRequest: Bool = false
    @Published var deletingRequest: Bool = false
    
    @Published var loadingRequests: Bool = false
    @Published var requests: [ConnectionRequest] = []
    @Published var requestCount: Int = 0
    
    @Published var loadingBlockerUsers: Bool = false
    @Published var blockedUsers: [Connection] = []
    @Published var blockedUserCount: Int = 0
    
    @Published var error: Swift.Error?
    
    init() {
        
    }
    
    init(connections: [Connection], requests: [ConnectionRequest], blockedUsers: [Connection]) {
        self.connections = connections
        self.connectionCount = connections.count
        
        self.requests = requests
        self.requestCount = requests.count
        
        self.blockedUsers = blockedUsers
        self.blockedUserCount = blockedUsers.count
    }
    
    private func url(nameFilter: String?, inSync: Bool?) throws -> URL {
        if (self.authorization == nil) {
            throw GenericError("Not logged in")
        }
        
        let userId: String? = self.authorization?.id
        var urlString = "\(BuildConfiguration.shared.baseURL)/user/v1/users/\(userId!)/connections"
        
        if nameFilter != nil && nameFilter!.count >= 3 {
            urlString = "\(urlString)?name=\(nameFilter!)"
        }
        
        if inSync != nil {
            urlString = "\(urlString)\(urlString.contains("?") ? "&": "?")inSync=\(inSync!)"
        }
        
        return URL(string: urlString)!
    }
    
    private func requestsUrl() throws -> URL {
        if (self.authorization == nil) {
            throw GenericError("Not logged in")
        }
        
        let userId: String? = self.authorization?.id
        return URL(string: "\(BuildConfiguration.shared.baseURL)/user/v1/users/\(userId!)/connections/requests/pending")!
    }
    
    private func deleteRequestUrl() throws -> URL {
        if (self.authorization == nil) {
            throw GenericError("Not logged in")
        }
        
        let userId: String? = self.authorization?.id
        return URL(string: "\(BuildConfiguration.shared.baseURL)/user/v1/users/\(userId!)/connections/requests/deny")!
    }
    
    private func confirmRequestUrl() throws -> URL {
        if (self.authorization == nil) {
            throw GenericError("Not logged in")
        }
        
        let userId: String? = self.authorization?.id
        return URL(string: "\(BuildConfiguration.shared.baseURL)/user/v1/users/\(userId!)/connections/requests/confirm")!
    }
    
    private func rejectedUsersUrl() throws -> URL {
        if (self.authorization == nil) {
            throw GenericError("Not logged in")
        }
        
        let userId: String? = self.authorization?.id
        return URL(string: "\(BuildConfiguration.shared.baseURL)/user/v1/users/\(userId!)/connections/rejected")!
    }
    
    func load() {
        self.load(nameFilter: nil, permissionGroup: nil)
    }
    
    func load(nameFilter: String?, permissionGroup: String?) {
        do {
            self.loading = true
            let idToken: String? = self.authorization?.idToken
            URLSession.shared.fetchData(for: try self.url(nameFilter: nameFilter, inSync: nil), for: "Bearer \(idToken!)") { (result: Result<ConnectionResponse, Error>) in
                switch result {
                case .success(let response):
                    self.connections = response.users
                    self.connectionCount = response.count
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
    
    func loadOutOfSync(callback: @escaping (Result<ConnectionResponse, Error>) -> Void) {
        do {
            let idToken: String? = self.authorization?.idToken
            URLSession.shared.fetchData(for: try self.url(nameFilter: nil, inSync: false), for: "Bearer \(idToken!)") { (result: Result<ConnectionResponse, Error>) in
                switch result {
                case .success(let response):
                    self.outOfSyncCount = response.count
                    callback(.success(response))
                case .failure(let error):
                    callback(.failure(error))
                }
            }
        } catch(let error) {
            callback(.failure(error))
        }
    }
    
    func loadRejectedUsers() {
        do {
            self.loadingBlockerUsers = true
            let idToken: String? = self.authorization?.idToken
            URLSession.shared.fetchData(for: try self.rejectedUsersUrl(), for: "Bearer \(idToken!)") { (result: Result<[Connection], Error>) in
                switch result {
                case .success(let users):
                    self.blockedUsers = users
                    self.blockedUserCount = users.count
                case .failure(let error):
                    self.error = GenericError(error.localizedDescription)
                }
                self.loadingBlockerUsers = false
            }
        } catch(let error) {
            self.error = GenericError(error.localizedDescription)
            self.loadingBlockerUsers = false
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
                    self.requestCount = requests.count
                case .failure(let error):
                    self.error = GenericError(error.localizedDescription)
                }
                self.loadingRequests = false
            }
        } catch(let error) {
            self.error = GenericError(error.localizedDescription)
            self.loadingRequests = false
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
                    self.error = GenericError(error.localizedDescription)
                    callback(.failure(error))
                }
                self.deletingRequest = false
            }
        } catch(let error) {
            self.error = GenericError(error.localizedDescription)
            self.deletingRequest = false
        }
    }
    
    func confirmRequest(otherUserId: String, permissionGroup: String, callback: @escaping (Result<Bool, Error>) -> Void) {
        do {
            self.confirmingRequest = true
            let idToken: String? = self.authorization?.idToken
            let request = ConfirmRequest(otherUserId: otherUserId, permissionGroupName: permissionGroup)
            URLSession.shared.postData(for: try self.confirmRequestUrl(), for: request, for: "Bearer \(idToken!)") { (result: Result<ConfirmResponse, Error>) in
                switch result {
                case .success(_):
                    callback(.success(true))
                case .failure(let error):
                    self.error = GenericError(error.localizedDescription)
                    callback(.failure(error))
                }
                self.confirmingRequest = false
            }
        } catch(let error) {
            self.error = GenericError(error.localizedDescription)
            self.confirmingRequest = false
        }
    }
    
    struct DenyRequest : Encodable {
        var otherUserId: String
    }
    
    struct ConfirmRequest : Encodable {
        var otherUserId: String
        var permissionGroupName: String
    }
    
    struct DeleteResponse : Decodable {
        
    }
    
    struct ConfirmResponse : Decodable {
        
    }
}
