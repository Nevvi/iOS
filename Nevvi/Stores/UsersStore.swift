//
//  UsersStore.swift
//  Nevvi
//
//  Created by Tyler Cobb on 12/31/22.
//

import Foundation

class UsersStore : ObservableObject {
    var authorization: Authorization? = nil
    
    @Published var requesting: Bool = false
    @Published var loading: Bool = false
    @Published var users: [Connection] = []
    @Published var userCount: Int = 0
        
    init() {
        
    }
    
    init(users: [Connection]) {
        self.users = users
    }
    
    private func url(nameFilter: String) throws -> URL {
        if (self.authorization == nil) {
            throw GenericError("Not logged in")
        }
        
        let url = "https://api.development.nevvi.net/user/v1/users/search?name=\(nameFilter)"
        let urlString = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        return URL(string: urlString)!
    }
    
    private func requestUrl() throws -> URL {
        if (self.authorization == nil) {
            throw GenericError("Not logged in")
        }
        
        let userId: String? = self.authorization?.id
        return URL(string: "https://api.development.nevvi.net/user/v1/users/\(userId!)/connections/requests")!
    }
    
    func load(nameFilter: String) {
        do {
            if (nameFilter.count < 3) {
                self.users = []
                self.userCount = 0
                return
            }
            
            self.loading = true
            let idToken: String? = self.authorization?.idToken
            URLSession.shared.fetchData(for: try self.url(nameFilter: nameFilter), for: "Bearer \(idToken!)") { (result: Result<ConnectionResponse, Error>) in
                switch result {
                case .success(let response):
                    self.users = response.users
                    self.userCount = response.count
                case .failure(let error):
                    print(error)
                }
                self.loading = false
            }
        } catch(let error) {
            print("Failed to load connections", error)
        }
    }
    
    func requestConnection(userId: String, groupName: String) {
        do {
            self.requesting = true
            let idToken: String? = self.authorization?.idToken
            var request = NewConnectionRequest(otherUserId: userId, permissionGroupName: groupName)
            URLSession.shared.postData(for: try self.requestUrl(), for: request, for: "Bearer \(idToken!)") { (result: Result<ConnectionRequestResponse, Error>) in
                switch result {
                case .success(_):
                    print("Success!")
                case .failure(let error):
                    print(error)
                }
                self.requesting = false
            }
        } catch(let error) {
            print("Failed to request connection", error)
        }
    }
    
    struct NewConnectionRequest: Encodable {
        var otherUserId: String
        var permissionGroupName: String
    }
    
    struct ConnectionRequestResponse: Decodable {
        
    }
}
