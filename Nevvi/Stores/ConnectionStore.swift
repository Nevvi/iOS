//
//  ConnectionStore.swift
//  Nevvi
//
//  Created by Tyler Cobb on 12/31/22.
//

import Foundation

class ConnectionStore : ObservableObject {
    var authorization: Authorization? = nil
        
    @Published var id: String = ""
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    @Published var bio: String = ""
    @Published var email: String = ""
    @Published var phoneNumber: String = ""
    @Published var birthday: Date = Date()
    @Published var address: AddressViewModel = AddressViewModel()
    @Published var permissionGroup: String = "ALL"
    @Published var profileImage: String = "https://nevvi-user-images.s3.amazonaws.com/Default_Profile_Picture.png"
    
    @Published var saving: Bool = false
    @Published var loading: Bool = false
    @Published var deleting: Bool = false
    
    @Published var error: Swift.Error?
    
    init() {
        
    }
    
    init(connection: Connection) {
        self.update(connection: connection)
    }
    
    func update(connection: Connection) {
        self.id = connection.id
        self.firstName = connection.firstName
        self.lastName = connection.lastName
        self.bio = connection.bio == nil ? "" : connection.bio!
        self.email = connection.email == nil ? "" : connection.email!
        self.phoneNumber = connection.phoneNumber == nil ? "" : connection.phoneNumber!
        self.birthday = connection.birthday == nil ? Date() : connection.birthday!
        
        if (connection.address != nil) {
            self.address.update(address: connection.address!)
        } else {
            self.address = AddressViewModel()
        }
        
        self.profileImage = connection.profileImage
        self.permissionGroup = connection.permissionGroup != nil ? connection.permissionGroup! : "ALL"
    }
    
    private func reset() {
        self.id = ""
        self.firstName = ""
        self.lastName = ""
        self.bio = ""
        self.email = ""
        self.phoneNumber = ""
        self.birthday = Date()
        self.address = AddressViewModel()
        self.profileImage = "https://nevvi-user-images.s3.amazonaws.com/Default_Profile_Picture.png"
        self.permissionGroup = "ALL"
    }
    
    private func url(connectionId: String) throws -> URL {
        if (self.authorization == nil) {
            throw GenericError("Not logged in")
        }
        
        let userId: String? = self.authorization?.id
        return URL(string: "\(BuildConfiguration.shared.baseURL)/user/v1/users/\(userId!)/connections/\(connectionId)")!
    }
    
    func load(connectionId: String, callback: @escaping (Result<Connection, Error>) -> Void) {
        do {
            self.loading = true
            self.reset()
            let idToken: String? = self.authorization?.idToken
            URLSession.shared.fetchData(for: try self.url(connectionId: connectionId), for: "Bearer \(idToken!)") { (result: Result<Connection, Error>) in
                switch result {
                case .success(let connection):
                    self.update(connection: connection)
                    callback(.success(connection))
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
    
    func delete(connectionId: String, callback: @escaping (Result<Bool, Error>) -> Void) {
        do {
            self.deleting = true
            let idToken: String? = self.authorization?.idToken
            URLSession.shared.deleteData(for: try self.url(connectionId: connectionId), for: "Bearer \(idToken!)") { (result: Result<DeleteResponse, Error>) in
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
        }
    }
    
    func update(callback: @escaping (Result<Connection, Error>) -> Void) {
        do {
            self.saving = true
            let idToken: String? = self.authorization?.idToken
            let request = UpdateRequest(permissionGroupName: self.permissionGroup)
            URLSession.shared.patchData(for: try self.url(connectionId: self.id), for: request, for: "Bearer \(idToken!)") { (result: Result<Connection, Error>) in
                switch result {
                case .success(let connection):
                    self.update(connection: connection)
                    callback(.success(connection))
                case .failure(let error):
                    self.error = GenericError(error.localizedDescription)
                    callback(.failure(error))
                }
                self.saving = false
            }
        } catch(let error) {
            self.error = GenericError(error.localizedDescription)
            callback(.failure(error))
            self.saving = false
        }
    }
    
    struct UpdateRequest: Encodable {
        var permissionGroupName: String
    }
    
    struct DeleteResponse : Decodable {
        
    }
}
