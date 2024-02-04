//
//  ConnectionGroupStore.swift
//  Nevvi
//
//  Created by Tyler Cobb on 12/31/22.
//

import Foundation

class ConnectionGroupStore : ObservableObject {
    var authorization: Authorization? = nil
    
    @Published var loading: Bool = false
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
    }
    
    private func groupUrl(groupId: String) throws -> URL {
        if (self.authorization == nil) {
            throw GenericError("Not logged in")
        }
        
        let userId: String? = self.authorization?.id
        return URL(string: "\(BuildConfiguration.shared.baseURL)/user/v1/users/\(userId!)/connection-groups/\(groupId)")!
    }
    
    private func groupConnectionsUrl(groupId: String) throws -> URL {
        return try self.groupConnectionsUrl(groupId: groupId, name: nil)
    }
    
    private func groupConnectionsUrl(groupId: String, name: String?) throws -> URL {
        if (self.authorization == nil) {
            throw GenericError("Not logged in")
        }
        
        let userId: String? = self.authorization?.id
        var url = "\(BuildConfiguration.shared.baseURL)/user/v1/users/\(userId!)/connection-groups/\(groupId)/connections"
        if (name != nil && name != "") {
            url = "\(url)?name=\(name!)"
        }
        
        return URL(string: url)!
    }
    
    private func groupExportUrl(groupId: String) throws -> URL {
        if (self.authorization == nil) {
            throw GenericError("Not logged in")
        }
        
        let userId: String? = self.authorization?.id
        return URL(string: "\(BuildConfiguration.shared.baseURL)/user/v1/users/\(userId!)/connection-groups/\(groupId)/export")!
    }
    
    func load(group: ConnectionGroup) {
        self.id = group.id
        self.name = group.name
        self.loadConnections(groupId: group.id)
    }
    
    func loadConnections(groupId: String) {
        self.loadConnections(groupId: groupId, name: nil)
    }
    
    func loadConnections(groupId: String, name: String?) {
        do {
            self.loadingConnections = true
            let idToken: String? = self.authorization?.idToken
            URLSession.shared.fetchData(for: try self.groupConnectionsUrl(groupId: groupId, name: name), for: "Bearer \(idToken!)") { (result: Result<ConnectionResponse, Error>) in
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
    
    func isConnectionInGroup(connection: Connection) -> Bool {
        return self.connections.contains { groupConnection in
            return groupConnection.id == connection.id
        }
    }
    
    func addToGroup(userId: String, callback: @escaping (Result<Bool, Error>) -> Void) {
        do {
            self.loading = true
            let idToken: String? = self.authorization?.idToken
            let request = AddToGroupRequest(userId: userId)
            URLSession.shared.postData(for: try self.groupConnectionsUrl(groupId: self.id), for: request, for: "Bearer \(idToken!)") { (result: Result<EmptyResponse, Error>) in
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
            URLSession.shared.deleteData(for: try self.groupConnectionsUrl(groupId: self.id), for: request, for: "Bearer \(idToken!)") { (result: Result<EmptyResponse, Error>) in
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
            URLSession.shared.postData(for: try self.groupExportUrl(groupId: self.id), for: "Bearer \(idToken!)") { (result: Result<EmptyResponse, Error>) in
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
