//
//  ConnectionGroupStore.swift
//  Nevvi
//
//  Created by Tyler Cobb on 12/31/22.
//

import Foundation

class ConnectionGroupStore : ObservableObject {
    var authorization: Authorization? = nil
    
    // TODO - pagination not actually used yet so default to a high limit and just grab all connections right now (500 is max limit)
    private var skip: Int = 0
    private var limit: Int = 500
    
    @Published var loading: Bool = false
    @Published var loadingPage: Bool = false
    @Published var loadingConnections: Bool = false
    @Published var deleting: Bool = false
    @Published var exporting: Bool = false
    
    @Published var id: String = ""
    @Published var name: String = ""
    @Published var connections: [Connection] = []
    @Published var connectionCount: Int = 0
    
    @Published var error: Swift.Error?
    
    init() {
        
    }
    
    init(group: ConnectionGroup, connections: [Connection]) {
        self.id = group.id
        self.name = group.name
        self.connections = connections
        self.connectionCount = connections.count
        self.skip = 0
    }
    
    private func groupUrl(groupId: String) throws -> URL {
        if (self.authorization == nil) {
            throw GenericError("Not logged in")
        }
        
        let userId: String? = self.authorization?.id
        return URL(string: "\(BuildConfiguration.shared.baseURL)/user/v1/users/\(userId!)/connection-groups/\(groupId)?skip=\(self.skip)&limit=\(self.limit)")!
    }
    
    private func groupConnectionsUrl() throws -> URL {
        if (self.authorization == nil) {
            throw GenericError("Not logged in")
        }
        
        let userId: String? = self.authorization?.id
        let url = "\(BuildConfiguration.shared.baseURL)/user/v1/users/\(userId!)/connection-groups/\(self.id)/connections?skip=\(self.skip)&limit=\(self.limit)"
        
        return URL(string: url)!
    }
    
    private func groupExportUrl() throws -> URL {
        if (self.authorization == nil) {
            throw GenericError("Not logged in")
        }
        
        let userId: String? = self.authorization?.id
        return URL(string: "\(BuildConfiguration.shared.baseURL)/user/v1/users/\(userId!)/connection-groups/\(self.id)/export")!
    }
    
    func load(group: ConnectionGroup) {
        self.id = group.id
        self.name = group.name
        self.skip = 0
        self.loadConnections()
    }
    
    func loadConnections() {
        do {
            self.loadingConnections = true
            let idToken: String? = self.authorization?.idToken
            URLSession.shared.fetchData(for: try self.groupConnectionsUrl(), for: "Bearer \(idToken!)") { (result: Result<ConnectionResponse, Error>) in
                switch result {
                case .success(let response):
                    self.connections = response.users
                    self.connectionCount = response.count
                case .failure(let error):
                    self.error = GenericError(error.localizedDescription)
                }
                self.loadingConnections = false
            }
        } catch(let error) {
            self.error = GenericError(error.localizedDescription)
            self.loadingConnections = false
        }
    }
    
    func hasNextPage() -> Bool {
        return self.connections.count < self.connectionCount
    }
    
    /// TODO - not actually called yet as it would break other business logic
    func loadNextPage() {
        if !self.hasNextPage() {
            return
        }
        
        do {
            self.loadingPage = true
            let idToken: String? = self.authorization?.idToken
            self.skip = self.skip + self.limit
            
            URLSession.shared.fetchData(for: try self.groupConnectionsUrl(), for: "Bearer \(idToken!)") { (result: Result<ConnectionResponse, Error>) in
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
    
    func isConnectionInGroup(connection: Connection) -> Bool {
        // TODO - call to get connections is paginated so this may not contain every actual connection in the group
        return self.connections.contains { groupConnection in
            return groupConnection.id == connection.id
        }
    }
    
    func addToGroup(userId: String, callback: @escaping (Result<Bool, Error>) -> Void) {
        do {
            self.loading = true
            let idToken: String? = self.authorization?.idToken
            let request = AddToGroupRequest(userId: userId)
            URLSession.shared.postData(for: try self.groupConnectionsUrl(), for: request, for: "Bearer \(idToken!)") { (result: Result<EmptyResponse, Error>) in
                switch result {
                case .success(_):
                    callback(.success(true))
                case .failure(let error):
                    self.error = GenericError(error.localizedDescription)
                    callback(.failure(error))
                }
                self.loading = false
            }
        } catch(let error) {
            self.error = GenericError(error.localizedDescription)
            callback(.failure(error))
            self.loading = false
        }
    }
    
    func removeFromGroup(userId: String, callback: @escaping (Result<Bool, Error>) -> Void) {
        do {
            self.deleting = true
            let idToken: String? = self.authorization?.idToken
            let request = RemoveFromGroupRequest(userId: userId)
            URLSession.shared.deleteData(for: try self.groupConnectionsUrl(), for: request, for: "Bearer \(idToken!)") { (result: Result<EmptyResponse, Error>) in
                switch result {
                case .success(_):
                    callback(.success(true))
                case .failure(let error):
                    self.error = GenericError(error.localizedDescription)
                    callback(.failure(error))
                }
                self.deleting = false
            }
        } catch(let error) {
            self.error = GenericError(error.localizedDescription)
            callback(.failure(error))
            self.deleting = false
        }
    }
    
    func exportGroupData(callback: @escaping (Result<Bool, Error>) -> Void) {
        do {
            self.exporting = true
            let idToken: String? = self.authorization?.idToken
            URLSession.shared.postData(for: try self.groupExportUrl(), for: "Bearer \(idToken!)") { (result: Result<EmptyResponse, Error>) in
                switch result {
                case .success(_):
                    callback(.success(true))
                case .failure(let error):
                    self.error = GenericError(error.localizedDescription)
                    callback(.failure(error))
                }
                self.exporting = false
            }
        } catch(let error) {
            self.error = GenericError(error.localizedDescription)
            callback(.failure(error))
            self.exporting = false
        }
    }

    struct AddToGroupRequest : Encodable {
        var userId: String
    }
    
    struct RemoveFromGroupRequest : Encodable {
        var userId: String
    }
    
    struct EmptyResponse : Decodable {
        
    }
    
}
