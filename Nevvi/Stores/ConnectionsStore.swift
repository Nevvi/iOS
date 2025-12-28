//
//  ConnectionsStore.swift
//  Nevvi
//
//  Created by Tyler Cobb on 12/31/22.
//

import Foundation

class ConnectionsStore : ObservableObject {
    @Published var authorization: Authorization? = nil {
        didSet {
            // Reset all state when authorization changes to prevent stale data issues
            if authorization == nil {
                // Reset loading states immediately on main thread
                DispatchQueue.main.async {
                    self.loading = false
                    self.loadingPage = false
                    self.loadingRequests = false
                    self.loadingBlockerUsers = false
                    self.confirmingRequest = false
                    self.deletingRequest = false
                    self.error = nil
                    
                    // Clear all data
                    self.connections = []
                    self.connectionCount = 0
                    self.outOfSyncCount = 0
                    self.requests = []
                    self.requestCount = 0
                    self.blockedUsers = []
                    self.blockedUserCount = 0
                    
                    // Reset pagination
                    self.skip = 0
                    self.nameFilter = nil
                    self.permissionGroup = nil
                }
            } else if oldValue == nil && authorization != nil {
                // Authorization was set for the first time (login), load initial data
                DispatchQueue.main.async {
                    self.load()
                    self.loadRequests()
                    self.loadRejectedUsers()
                    self.loadOutOfSync { _ in }
                }
            }
        }
    }
    
    private var nameFilter: String? = nil
    private var permissionGroup: String? = nil
    private var skip: Int = 0
    private var limit: Int = 25
    
    @Published var loading: Bool = false
    @Published var loadingPage: Bool = false
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
    
    private func url(inSync: Bool?) throws -> URL {
        if (self.authorization == nil) {
            throw GenericError("Not logged in")
        }
        
        let userId: String = self.authorization!.id
        var urlString = "\(BuildConfiguration.shared.baseURL)/user/v1/users/\(userId)/connections?skip=\(self.skip)&limit=\(self.limit)"
        
        if self.nameFilter != nil && self.nameFilter!.count > 0 {
            urlString = "\(urlString)&name=\(self.nameFilter!)"
        }
        
        if self.permissionGroup != nil {
            urlString = "\(urlString)&permissionGroup=\(self.permissionGroup!)"
        }
        
        if inSync != nil {
            urlString = "\(urlString)&inSync=\(inSync!)"
        }
        
        return URL(string: urlString)!
    }
    
    private func requestsUrl() throws -> URL {
        if (self.authorization == nil) {
            throw GenericError("Not logged in")
        }
        
        let userId: String = self.authorization!.id
        return URL(string: "\(BuildConfiguration.shared.baseURL)/user/v1/users/\(userId)/connections/requests/pending")!
    }
    
    private func deleteRequestUrl() throws -> URL {
        if (self.authorization == nil) {
            throw GenericError("Not logged in")
        }
        
        let userId: String = self.authorization!.id
        return URL(string: "\(BuildConfiguration.shared.baseURL)/user/v1/users/\(userId)/connections/requests/deny")!
    }
    
    private func confirmRequestUrl() throws -> URL {
        if (self.authorization == nil) {
            throw GenericError("Not logged in")
        }
        
        let userId: String = self.authorization!.id
        return URL(string: "\(BuildConfiguration.shared.baseURL)/user/v1/users/\(userId)/connections/requests/confirm")!
    }
    
    private func rejectedUsersUrl() throws -> URL {
        if (self.authorization == nil) {
            throw GenericError("Not logged in")
        }
        
        let userId: String = self.authorization!.id
        return URL(string: "\(BuildConfiguration.shared.baseURL)/user/v1/users/\(userId)/connections/rejected")!
    }
    
    func load() {
        self.load(nameFilter: nil, permissionGroup: nil)
    }
    
    func load(nameFilter: String?, permissionGroup: String?) {
        do {
            guard let authorization = self.authorization else {
                let error = GenericError("Not logged in")
                self.error = error
                self.loading = false
                return
            }
            
            self.loading = true
            
            // When a search param changes always reset the skip amount back to 0
            if self.nameFilter != nameFilter || self.permissionGroup != permissionGroup {
                self.skip = 0
            }
            
            self.nameFilter = nameFilter
            self.permissionGroup = permissionGroup
            
            URLSession.shared.fetchData(for: try self.url(inSync: nil), with: authorization) { (result: Result<ConnectionResponse, Error>) in
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
    
    func hasNextPage() -> Bool {
        return self.connections.count < self.connectionCount
    }
    
    func loadNextPage() {
        if !self.hasNextPage() {
            return
        }
        
        do {
            guard let authorization = self.authorization else {
                let error = GenericError("Not logged in")
                self.error = error
                self.loadingPage = false
                return
            }
            
            self.loadingPage = true
            self.skip = self.skip + self.limit
            
            URLSession.shared.fetchData(for: try self.url(inSync: nil), with: authorization) { (result: Result<ConnectionResponse, Error>) in
                switch result {
                case .success(let response):
                    // When loading a page we want to append to the list, not overwrite it
                    self.connections.append(contentsOf: response.users)
                case .failure(let error):
                    self.error = GenericError(error.localizedDescription)
                }
                self.loadingPage = false
            }
        } catch(let error) {
            self.loadingPage = false
            self.error = GenericError(error.localizedDescription)
        }
    }
    
    func loadOutOfSync(callback: @escaping (Result<ConnectionResponse, Error>) -> Void) {
        do {
            guard let authorization = self.authorization else {
                let error = GenericError("Not logged in")
                callback(.failure(error))
                return
            }
            
            self.nameFilter = nil
            self.permissionGroup = nil
            self.skip = 0
            
            URLSession.shared.fetchData(for: try self.url(inSync: false), with: authorization) { (result: Result<ConnectionResponse, Error>) in
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
            guard let authorization = self.authorization else {
                let error = GenericError("Not logged in")
                self.error = error
                self.loadingBlockerUsers = false
                return
            }
            
            self.loadingBlockerUsers = true
            URLSession.shared.fetchData(for: try self.rejectedUsersUrl(), with: authorization) { (result: Result<[Connection], Error>) in
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
            guard let authorization = self.authorization else {
                let error = GenericError("Not logged in")
                self.error = error
                self.loadingRequests = false
                return
            }
            
            self.loadingRequests = true
            URLSession.shared.fetchData(for: try self.requestsUrl(), with: authorization) { (result: Result<[ConnectionRequest], Error>) in
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
            guard let authorization = self.authorization else {
                let error = GenericError("Not logged in")
                self.error = error
                callback(.failure(error))
                self.deletingRequest = false
                return
            }
            
            self.deletingRequest = true
            let request = DenyRequest(otherUserId: otherUserId)
            URLSession.shared.postData(for: try self.deleteRequestUrl(), for: request, with: authorization) { (result: Result<DeleteResponse, Error>) in
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
            guard let authorization = self.authorization else {
                let error = GenericError("Not logged in")
                self.error = error
                callback(.failure(error))
                self.confirmingRequest = false
                return
            }
            
            self.confirmingRequest = true
            let request = ConfirmRequest(otherUserId: otherUserId, permissionGroupName: permissionGroup)
            URLSession.shared.postData(for: try self.confirmRequestUrl(), for: request, with: authorization) { (result: Result<ConfirmResponse, Error>) in
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
