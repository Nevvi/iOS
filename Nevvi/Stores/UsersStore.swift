//
//  UsersStore.swift
//  Nevvi
//
//  Created by Tyler Cobb on 12/31/22.
//

import Foundation

class UsersStore : ObservableObject {
    var authorization: Authorization? = nil
    
    @Published var inviting: Bool = false
    @Published var requesting: Bool = false
    @Published var loading: Bool = false
    @Published var users: [Connection] = []
    @Published var userCount: Int = 0
    
    @Published var error: Swift.Error?
        
    init() {
        
    }
    
    init(users: [Connection]) {
        self.users = users
        self.userCount = users.count
    }
    
    private func url(nameFilter: String?) throws -> URL {
        if (self.authorization == nil) {
            throw GenericError("Not logged in")
        }
        
        var url = "\(BuildConfiguration.shared.baseURL)/user/v1/users/search"
        if (nameFilter != nil) {
            url = "\(url)?name=\(nameFilter!)"
        }
        
        let urlString = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        return URL(string: urlString)!
    }
    
    private func requestUrl() throws -> URL {
        if (self.authorization == nil) {
            throw GenericError("Not logged in")
        }
        
        let userId: String? = self.authorization?.id
        return URL(string: "\(BuildConfiguration.shared.baseURL)/user/v1/users/\(userId!)/connections/requests")!
    }
    
    private func inviteUrl() throws -> URL {
        if (self.authorization == nil) {
            throw GenericError("Not logged in")
        }
        
        let userId: String? = self.authorization?.id
        return URL(string: "\(BuildConfiguration.shared.baseURL)/user/v1/users/\(userId!)/invite".urlEncoded()!)!
    }
    
    func searchByName(nameFilter: String) {
        do {
            if (nameFilter.count < 3) {
                self.users = []
                self.userCount = 0
                return
            }
            
            self.search(url: try self.url(nameFilter: nameFilter))
        } catch(let error) {
            self.error = GenericError(error.localizedDescription)
            self.loading = false
        }
    }
    
    private func search(url: URL) {
        self.loading = true
        let idToken: String? = self.authorization?.idToken
        URLSession.shared.fetchData(for: url, for: "Bearer \(idToken!)") { (result: Result<ConnectionResponse, Error>) in
            switch result {
            case .success(let response):
                self.users = response.users
                self.userCount = response.count
            case .failure(let error):
                self.error = GenericError(error.localizedDescription)
            }
            self.loading = false
        }
    }
    
    func requestConnection(userId: String, groupName: String, callback: @escaping (Result<Bool, Error>) -> Void) {
        do {
            self.requesting = true
            let idToken: String? = self.authorization?.idToken
            let request = NewConnectionRequest(otherUserId: userId, permissionGroupName: groupName)
            URLSession.shared.postData(for: try self.requestUrl(), for: request, for: "Bearer \(idToken!)") { (result: Result<ConnectionRequestResponse, Error>) in
                switch result {
                case .success(_):
                    callback(.success(true))
                case .failure(let error):
                    self.error = GenericError(error.localizedDescription)
                    callback(.failure(error))
                }
                self.requesting = false
            }
        } catch(let error) {
            self.error = GenericError(error.localizedDescription)
            callback(.failure(error))
            self.requesting = false
        }
    }
    
    func inviteConnection(phoneNumber: String, groupName: String, reason: String, callback: @escaping (Result<Bool, Error>) -> Void) {
        do {
            self.inviting = true
            let idToken: String? = self.authorization?.idToken
            let request = NewConnectionInvite(phoneNumber: phoneNumber, permissionGroupName: groupName, reason: reason)
            URLSession.shared.postData(for: try self.inviteUrl(), for: request, for: "Bearer \(idToken!)") { (result: Result<ConnectionInviteResponse, Error>) in
                switch result {
                case .success(_):
                    callback(.success(true))
                case .failure(let error):
                    self.error = GenericError(error.localizedDescription)
                    callback(.failure(error))
                }
                self.inviting = false
            }
        } catch(let error) {
            self.error = GenericError(error.localizedDescription)
            callback(.failure(error))
            self.inviting = false
        }
    }
    
    func removeUser(user: Connection) {
        self.users = self.users.filter { $0 != user }
        
        // TODO - Need to be smarter about this
        self.userCount = self.userCount - 1
    }
    
    func reset() {
        self.users = []
        self.userCount = 0
    }
    
    struct NewConnectionRequest: Encodable {
        var otherUserId: String
        var permissionGroupName: String
    }
    
    struct NewConnectionInvite: Encodable {
        var phoneNumber: String
        var permissionGroupName: String
        var reason: String
    }
    
    struct ConnectionRequestResponse: Decodable {
        
    }
    
    struct ConnectionInviteResponse: Decodable {
        
    }
}
