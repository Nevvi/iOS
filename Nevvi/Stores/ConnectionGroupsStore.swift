//
//  ConnectionsStore.swift
//  Nevvi
//
//  Created by Tyler Cobb on 12/31/22.
//

import Foundation

class ConnectionGroupsStore : ObservableObject {
    @Published var authorization: Authorization? = nil {
        didSet {
            // Reset all state when authorization changes to prevent stale data issues
            if authorization == nil {
                // Reset loading states
                deleting = false
                creating = false
                loading = false
                adding = false
                removing = false
                error = nil
                
                // Clear all data
                groups = []
                groupsCount = 0
            } else if oldValue == nil && authorization != nil {
                // Authorization was set for the first time (login), load initial data
                DispatchQueue.main.async {
                    self.load()
                }
            }
        }
    }
    
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
        
        let userId: String = self.authorization!.id
        return URL(string: "\(BuildConfiguration.shared.baseURL)/user/v1/users/\(userId)/connection-groups")!
    }
    
    private func groupUrl(groupId: String) throws -> URL {
        if (self.authorization == nil) {
            throw GenericError("Not logged in")
        }
        
        let userId: String = self.authorization!.id
        return URL(string: "\(BuildConfiguration.shared.baseURL)/user/v1/users/\(userId)/connection-groups/\(groupId)")!
    }
    
    private func groupConnectionsUrl(groupId: String) throws -> URL {
        if (self.authorization == nil) {
            throw GenericError("Not logged in")
        }
        
        let userId: String = self.authorization!.id
        return URL(string: "\(BuildConfiguration.shared.baseURL)/user/v1/users/\(userId)/connection-groups/\(groupId)/connections")!
    }
    
    func load() {
        do {
            guard let authorization = self.authorization else {
                let error = GenericError("Not logged in")
                self.error = error
                self.loading = false
                return
            }
            
            self.loading = true
            URLSession.shared.fetchData(for: try self.url(), with: authorization) { (result: Result<[ConnectionGroup], Error>) in
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
            guard let authorization = self.authorization else {
                let error = GenericError("Not logged in")
                self.error = error
                callback(.failure(error))
                self.creating = false
                return
            }
            
            self.creating = true
            let request = CreateGroupRequest(name: name)
            URLSession.shared.postData(for: try self.url(), for: request, with: authorization) { (result: Result<ConnectionGroup, Error>) in
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
            guard let authorization = self.authorization else {
                let error = GenericError("Not logged in")
                self.error = error
                callback(.failure(error))
                self.deleting = false
                return
            }
            
            self.deleting = true
            URLSession.shared.deleteData(for: try self.groupUrl(groupId: groupId), with: authorization) { (result: Result<EmptyResponse, Error>) in
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
            guard let authorization = self.authorization else {
                let error = GenericError("Not logged in")
                self.error = error
                callback(.failure(error))
                self.adding = false
                return
            }
            
            self.adding = true
            let request = AddToGroupRequest(userId: userId)
            URLSession.shared.postData(for: try self.groupConnectionsUrl(groupId: groupId), for: request, with: authorization) { (result: Result<EmptyResponse, Error>) in
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
            guard let authorization = self.authorization else {
                let error = GenericError("Not logged in")
                self.error = error
                callback(.failure(error))
                self.removing = false
                return
            }
            
            self.removing = true
            let request = RemoveFromGroupRequest(userId: userId)
            URLSession.shared.deleteData(for: try self.groupConnectionsUrl(groupId: groupId), for: request, with: authorization) { (result: Result<EmptyResponse, Error>) in
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
