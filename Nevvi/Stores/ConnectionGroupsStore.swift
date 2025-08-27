//
//  ConnectionsStore.swift
//  Nevvi
//
//  Created by Tyler Cobb on 12/31/22.
//

import Foundation

class ConnectionGroupsStore : ObservableObject {
    var authorization: Authorization? = nil
    
    @Published var deleting: Bool = false
    @Published var creating: Bool = false
    @Published var loading: Bool = false
    @Published var adding: Bool = false
    @Published var removing: Bool = false
    
    @Published var groups: [ConnectionGroup] = []
    @Published var groupsCount: Int = 0
    
    @Published var error: Swift.Error?
    
    init() {
        
    }
    
    init(groups: [ConnectionGroup]) {
        self.groups = groups
        self.groupsCount = groups.count
    }
    
    private func url() throws -> URL {
        if (self.authorization == nil) {
            throw GenericError("Not logged in")
        }
        
        let userId: String? = self.authorization?.id
        return URL(string: "\(BuildConfiguration.shared.baseURL)/user/v1/users/\(userId!)/connection-groups")!
    }
    
    private func groupUrl(groupId: String) throws -> URL {
        if (self.authorization == nil) {
            throw GenericError("Not logged in")
        }
        
        let userId: String? = self.authorization?.id
        return URL(string: "\(BuildConfiguration.shared.baseURL)/user/v1/users/\(userId!)/connection-groups/\(groupId)")!
    }
    
    private func groupConnectionsUrl(groupId: String) throws -> URL {
        if (self.authorization == nil) {
            throw GenericError("Not logged in")
        }
        
        let userId: String? = self.authorization?.id
        return URL(string: "\(BuildConfiguration.shared.baseURL)/user/v1/users/\(userId!)/connection-groups/\(groupId)/connections")!
    }
    
    func load() {
        do {
            self.loading = true
            let idToken: String? = self.authorization?.idToken
            URLSession.shared.fetchData(for: try self.url(), for: "Bearer \(idToken!)") { (result: Result<[ConnectionGroup], Error>) in
                switch result {
                case .success(let groups):
                    self.groups = groups
                    self.groupsCount = groups.count
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
    
    func create(name: String, callback: @escaping (Result<ConnectionGroup, Error>) -> Void) {
        do {
            self.creating = true
            let idToken: String? = self.authorization?.idToken
            let request = CreateGroupRequest(name: name)
            URLSession.shared.postData(for: try self.url(), for: request, for: "Bearer \(idToken!)") { (result: Result<ConnectionGroup, Error>) in
                switch result {
                case .success(let group):
                    callback(.success(group))
                case .failure(let error):
                    self.error = GenericError(error.localizedDescription)
                    callback(.failure(error))
                }
                self.creating = false
            }
        } catch(let error) {
            self.error = GenericError(error.localizedDescription)
            self.creating = false
            callback(.failure(error))
        }
    }
    
    func delete(groupId: String, callback: @escaping (Result<Bool, Error>) -> Void) {
        do {
            self.deleting = true
            let idToken: String? = self.authorization?.idToken
            URLSession.shared.deleteData(for: try self.groupUrl(groupId: groupId), for: "Bearer \(idToken!)") { (result: Result<EmptyResponse, Error>) in
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
            self.deleting = false
            callback(.failure(error))
        }
    }
    
    func addToGroup(groupId: String, userId: String, callback: @escaping (Result<Bool, Error>) -> Void) {
        do {
            self.adding = true
            let idToken: String? = self.authorization?.idToken
            let request = AddToGroupRequest(userId: userId)
            URLSession.shared.postData(for: try self.groupConnectionsUrl(groupId: groupId), for: request, for: "Bearer \(idToken!)") { (result: Result<EmptyResponse, Error>) in
                switch result {
                case .success(_):
                    callback(.success(true))
                case .failure(let error):
                    self.error = GenericError(error.localizedDescription)
                    callback(.failure(error))
                }
                self.adding = false
            }
        } catch(let error) {
            self.error = GenericError(error.localizedDescription)
            self.adding = false
            callback(.failure(error))
        }
    }
    
    func removeFromGroup(groupId: String, userId: String, callback: @escaping (Result<Bool, Error>) -> Void) {
        do {
            self.removing = true
            let idToken: String? = self.authorization?.idToken
            let request = RemoveFromGroupRequest(userId: userId)
            URLSession.shared.deleteData(for: try self.groupConnectionsUrl(groupId: groupId), for: request, for: "Bearer \(idToken!)") { (result: Result<EmptyResponse, Error>) in
                switch result {
                case .success(_):
                    callback(.success(true))
                case .failure(let error):
                    self.error = GenericError(error.localizedDescription)
                    callback(.failure(error))
                }
                self.removing = false
            }
        } catch(let error) {
            self.error = GenericError(error.localizedDescription)
            self.removing = false
            callback(.failure(error))
        }
    }
    
    struct CreateGroupRequest : Encodable {
        var name: String
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
