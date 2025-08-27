//
//  AccountStore.swift
//  Nevvi
//
//  Created by Tyler Cobb on 12/29/22.
//

import Foundation
import UIKit
import SwiftUI

class AccountStore: ObservableObject {
    var authorization: Authorization? = nil
    
    @Published var loading: Bool = false
    @Published var saving: Bool = false
    @Published var savingImage: Bool = false
    
    // TODO - stash unsaved changes here and ability to revert?
    
    @Published var id: String = ""
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    @Published var bio: String = ""
    @Published var deviceId: String = ""
    @Published var email: String = ""
    @Published var emailConfirmed: Bool = false
    @Published var phoneNumber: String = ""
    @Published var phoneNumberConfirmed: Bool = false
    @Published var birthday: Date = Date()
    @Published var onboardingCompleted: Bool = false
    @Published var blockedUsers: [String] = []
    @Published var address: AddressViewModel = AddressViewModel()
    @Published var mailingAddress: AddressViewModel = AddressViewModel()
    @Published var permissionGroups: [PermissionGroup] = []
    @Published var profileImage: String = "https://nevvi-user-images.s3.amazonaws.com/Default_Profile_Picture.png"
    @Published var deviceSettings: DeviceSettingsViewModel = DeviceSettingsViewModel()
    
    @Published var error: Swift.Error?
    
    var user: User? = nil
    
    init() {
        
    }
    
    init(user: User) {
        self.update(user: user)
    }
    
    func update(user: User) {
        // keep track of the original user to monitor if anything changes
        self.user = user
        
        self.id = user.id
        self.phoneNumber = user.phoneNumber
        self.phoneNumberConfirmed = user.phoneNumberConfirmed
        
        self.firstName = user.firstName == nil ? "" : user.firstName!
        self.lastName = user.lastName == nil ? "" : user.lastName!
        self.bio = user.bio == nil ? "" : user.bio!
        self.deviceId = user.deviceId == nil ? "" : user.deviceId!
        self.email = user.email == nil ? "" : user.email!
        self.emailConfirmed = user.emailConfirmed == nil ? false : user.emailConfirmed!
        self.birthday = user.birthday == nil ? Date() : user.birthday!
        self.onboardingCompleted = user.onboardingCompleted
        self.blockedUsers = user.blockedUsers
        self.address.update(address: user.address)
        self.mailingAddress.update(address: user.mailingAddress)
        self.deviceSettings.update(settings: user.deviceSettings)
        self.permissionGroups = user.permissionGroups
        self.profileImage = user.profileImage
    }
    
    func updateImage(user: User) {
        self.user?.profileImage = user.profileImage
        self.profileImage = user.profileImage
    }
    
    func resetChanges() {
        guard let user = user else {
            return
        }
        
        self.update(user: user)
    }
    
    func reset() {
        self.user = nil
        
        self.id = ""
        self.firstName = ""
        self.lastName = ""
        self.bio = ""
        self.deviceId = "" // TODO - do we want this?
        self.email = ""
        self.emailConfirmed = false
        self.phoneNumber = ""
        self.phoneNumberConfirmed = false
        self.birthday = Date()
        self.onboardingCompleted = false
        self.blockedUsers = []
        self.address = AddressViewModel()
        self.mailingAddress = AddressViewModel()
        self.deviceSettings = DeviceSettingsViewModel()
        self.permissionGroups = []
        self.profileImage = "https://nevvi-user-images.s3.amazonaws.com/Default_Profile_Picture.png"
    }
    
    private func url() throws -> URL {
        if (self.authorization == nil) {
            throw GenericError("Not logged in")
        }
        
        let userId: String? = self.authorization?.id
        return URL(string: "\(BuildConfiguration.shared.baseURL)/user/v1/users/\(userId!)")!
    }
    
    private func imageUrl() throws -> URL {
        if (self.authorization == nil) {
            throw GenericError("Not logged in")
        }
        
        let userId: String? = self.authorization?.id
        return URL(string: "\(BuildConfiguration.shared.baseURL)/user/v1/users/\(userId!)/image")!
    }
    
    private func verifyEmailUrl() throws -> URL {
        if (self.authorization == nil) {
            throw GenericError("Not logged in")
        }
        
        let userId: String? = self.authorization?.id
        return URL(string: "\(BuildConfiguration.shared.baseURL)/authentication/v1/users/\(userId!)/sendCode?attribute=email")!
    }
    
    private func confirmEmailUrl(code: String) throws -> URL {
        if (self.authorization == nil) {
            throw GenericError("Not logged in")
        }
        
        let userId: String? = self.authorization?.id
        return URL(string: "\(BuildConfiguration.shared.baseURL)/authentication/v1/users/\(userId!)/confirmCode?attribute=email&code=\(code)")!
    }
    
    func load() {
        do {
            self.loading = true
            let idToken: String? = self.authorization?.idToken
            URLSession.shared.fetchData(for: try self.url(), for: "Bearer \(idToken!)") { (result: Result<User, Error>) in
                switch result {
                case .success(let user):
                    self.update(user: user)
                case .failure(let error):
                    self.error = GenericError(error.localizedDescription)
                }
                self.loading = false
                
                // If the user we got with this token doesn't match the device id then do an update
                if let uuid = UIDevice.current.identifierForVendor?.uuidString {
                    if self.deviceId != uuid {
                        // TODO - Future: prompt user to use this device for long term?
                        self.deviceId = uuid
                        self.save()
                    }
                }
            }
        } catch(let error) {
            self.error = GenericError(error.localizedDescription)
            self.loading = false
        }
    }
    
    func save() {
        self.save { (result: Result<User, Error>) in
            switch result {
            case .success(let user):
                self.update(user: user)
            case .failure(let error):
                self.error = GenericError(error.localizedDescription)
            }
        }
    }
    
    func save(callback: @escaping (Result<User, Error>) -> Void) {
        do {
            self.saving = true
            let idToken: String? = self.authorization?.idToken
            
            let request = PatchRequest(firstName: self.firstName != "" ? self.firstName : nil,
                                       lastName: self.lastName != "" ? self.lastName : nil,
                                       bio: self.bio != "" ? self.bio : nil,
                                       address: self.address.toModel(),
                                       mailingAddress: self.mailingAddress.toModel(),
                                       birthday: self.birthday.yyyyMMdd() != Date().yyyyMMdd() ? self.birthday.yyyyMMdd() : nil,
                                       email: self.email != "" ? self.email : nil,
                                       deviceId: self.deviceId,
                                       permissionGroups: self.permissionGroups,
                                       deviceSettings: self.deviceSettings.toModel())
            
            URLSession.shared.patchData(for: try self.url(), for: request, for: "Bearer \(idToken!)") { (result: Result<User, Error>) in
                switch result {
                case .success(let user):
                    self.update(user: user)
                    callback(.success(user))
                case .failure(let error):
                    self.error = GenericError(error.localizedDescription)
                    callback(.failure(error))
                }
                self.saving = false
            }
        } catch(let error) {
            self.error = GenericError(error.localizedDescription)
            self.saving = false
            callback(.failure(error))
        }
    }
    
    func update(request: PatchRequest, callback: @escaping (Result<User, Error>) -> Void) {
        do {
            self.saving = true
            let idToken: String? = self.authorization?.idToken
            URLSession.shared.patchData(for: try self.url(), for: request, for: "Bearer \(idToken!)") { (result: Result<User, Error>) in
                switch result {
                case .success(let user):
                    self.update(user: user)
                    callback(.success(user))
                case .failure(let error):
                    self.error = GenericError(error.localizedDescription)
                    callback(.failure(error))
                }
                self.saving = false
            }
        } catch(let error) {
            self.error = GenericError(error.localizedDescription)
            self.saving = false
            callback(.failure(error))
        }
    }
    
    func completeOnboarding(callback: @escaping (Result<User, Error>) -> Void) {
        do {
            self.saving = true
            let idToken: String? = self.authorization?.idToken
            let request = CompleteOnboardingRequest(onboardingCompleted: true)
            URLSession.shared.patchData(for: try self.url(), for: request, for: "Bearer \(idToken!)") { (result: Result<User, Error>) in
                switch result {
                case .success(let user):
                    self.update(user: user)
                    callback(.success(user))
                case .failure(let error):
                    self.error = GenericError(error.localizedDescription)
                    callback(.failure(error))
                }
                self.saving = false
            }
        } catch(let error) {
            self.error = GenericError(error.localizedDescription)
            self.saving = false
            callback(.failure(error))
        }
    }
    
    func uploadImage(image: UIImage, callback: @escaping (Result<User, Error>) -> Void) {
        do {
            self.savingImage = true
            let idToken: String? = self.authorization?.idToken
            URLSession.shared.postImage(for: try self.imageUrl(), for: image, for: "Bearer \(idToken!)") { (result: Result<User, Error>) in
                switch result {
                case .success(let user):
                    self.updateImage(user: user)
                    callback(.success(user))
                case .failure(let error):
                    self.error = GenericError(error.localizedDescription)
                    callback(.failure(error))
                }
                self.savingImage = false
            }
        } catch(let error) {
            self.error = GenericError(error.localizedDescription)
            self.savingImage = false
            callback(.failure(error))
        }
    }
    
    func verifyEmail(callback: @escaping (Result<VerifyResponse, Error>) -> Void) {
        do {
            self.saving = true
            let idToken: String? = self.authorization?.idToken
            let accessToken: String? = self.authorization?.accessToken
            URLSession.shared.postData(for: try self.verifyEmailUrl(), for: "Bearer \(idToken!)", for: accessToken!) { (result: Result<VerifyResponse, Error>) in
                switch result {
                case .success(let response):
                    callback(.success(response))
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
    
    func confirmEmail(code: String, callback: @escaping (Result<ConfirmResponse, Error>) -> Void) {
        do {
            self.saving = true
            let idToken: String? = self.authorization?.idToken
            let accessToken: String? = self.authorization?.accessToken
            URLSession.shared.postData(for: try self.confirmEmailUrl(code: code), for: "Bearer \(idToken!)", for: accessToken!) { (result: Result<ConfirmResponse, Error>) in
                switch result {
                case .success(let response):
                    callback(.success(response))
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
    
    func addPermissionGroup(newGroup: PermissionGroup, callback: @escaping (Result<User, Error>) -> Void) {
        if self.permissionGroups.contains(where: { group in group.name == newGroup.name }) {
            return
        }
        
        var permissionGroupsCopy = self.permissionGroups
        permissionGroupsCopy.append(newGroup)
        let request = PatchRequest(permissionGroups: permissionGroupsCopy)
        self.update(request: request, callback: callback)
    }
    
    func removePermissionGroup(existingGroup: PermissionGroup, callback: @escaping (Result<User, Error>) -> Void) {
        var permissionGroupsCopy = self.permissionGroups
        permissionGroupsCopy.removeAll(where: { group in group.name == existingGroup.name })
        let request = PatchRequest(permissionGroups: permissionGroupsCopy)
        self.update(request: request, callback: callback)
    }
    
    func delete(callback: @escaping (Result<String, Error>) -> Void) {
        do {
            self.loading = true
            let idToken: String? = self.authorization?.idToken
            URLSession.shared.deleteData(for: try self.url(), for: "Bearer \(idToken!)") { (result: Result<DeleteResponse, Error>) in
                switch result {
                case .success(let response):
                    callback(.success(response.message))
                case .failure(let error):
                    self.error = GenericError(error.localizedDescription)
                    callback(.failure(error))
                }
                self.loading = false
            }
        } catch(let error) {
            self.error = GenericError(error.localizedDescription)
            self.loading = false
        }
    }
    
    struct PatchRequest: Encodable {
        var firstName: String?
        var lastName: String?
        var bio: String?
        var address: Address?
        var mailingAddress: Address?
        var birthday: String?
        var email: String?
        var deviceId: String?
        var permissionGroups: [PermissionGroup]?
        var deviceSettings: DeviceSettings?
        var onboardingCompleted: Bool?
    }
    
    struct CompleteOnboardingRequest: Encodable {
        var onboardingCompleted: Bool
    }
    
    struct VerifyResponse: Decodable {
        var CodeDeliveryDetails: CodeDeliveryDetails
    }
    
    struct ConfirmResponse: Decodable {
        
    }
    
    struct CodeDeliveryDetails: Decodable {
        var Destination: String
        var DeliveryMedium: String
        var AttributeName: String
    }
    
    struct DeleteResponse: Decodable {
        var message: String
    }
}
