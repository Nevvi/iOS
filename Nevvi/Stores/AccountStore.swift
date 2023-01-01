//
//  AccountStore.swift
//  Nevvi
//
//  Created by Tyler Cobb on 12/29/22.
//

import Foundation
import UIKit

class AccountStore: ObservableObject {
    var authorization: Authorization? = nil
    
    @Published var user: User? = nil
    @Published var saving: Bool = false
    @Published var savingImage: Bool = false
    
    init() {
        
    }
    
    init(user: User) {
        self.user = user
    }
    
    private func url() throws -> URL {
        if (self.authorization == nil) {
            throw GenericError("Not logged in")
        }
        
        let userId: String? = self.authorization?.id
        return URL(string: "https://api.development.nevvi.net/user/v1/users/\(userId!)")!
    }
    
    private func imageUrl() throws -> URL {
        if (self.authorization == nil) {
            throw GenericError("Not logged in")
        }
        
        let userId: String? = self.authorization?.id
        return URL(string: "https://api.development.nevvi.net/user/v1/users/\(userId!)/image")!
    }
    
    private func verifyPhoneUrl() throws -> URL {
        if (self.authorization == nil) {
            throw GenericError("Not logged in")
        }
        
        let userId: String? = self.authorization?.id
        return URL(string: "https://api.development.nevvi.net/authentication/v1/users/\(userId!)/sendCode?attribute=phone_number")!
    }
    
    private func confirmPhoneUrl(code: String) throws -> URL {
        if (self.authorization == nil) {
            throw GenericError("Not logged in")
        }
        
        let userId: String? = self.authorization?.id
        return URL(string: "https://api.development.nevvi.net/authentication/v1/users/\(userId!)/confirmCode?attribute=phone_number&code=\(code)")!
    }
    
    func load() {
        do {
            let idToken: String? = self.authorization?.idToken
            URLSession.shared.fetchData(for: try self.url(), for: "Bearer \(idToken!)") { (result: Result<User, Error>) in
                switch result {
                case .success(let user):
                    self.user = user
                case .failure(let error):
                    print(error)
                }
            }
        } catch(let error) {
            print("Failed to load user", error)
        }
    }
    
    func update(firstName: String, lastName: String, callback: @escaping (Result<User, Error>) -> Void) {
        do {
            self.saving = true
            let idToken: String? = self.authorization?.idToken
            let request = PatchRequest(firstName: firstName, lastName: lastName)
            URLSession.shared.patchData(for: try self.url(), for: request, for: "Bearer \(idToken!)") { (result: Result<User, Error>) in
                switch result {
                case .success(let user):
                    self.user = user
                    callback(.success(user))
                case .failure(let error):
                    callback(.failure(error))
                }
                self.saving = false
            }
        } catch(let error) {
            print("Failed to save user", error)
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
                    self.user = user
                    callback(.success(user))
                case .failure(let error):
                    callback(.failure(error))
                }
                self.saving = false
            }
        } catch(let error) {
            print("Failed to save user", error)
            callback(.failure(error))
        }
    }
    
    func uploadImage(image: UIImage, callback: @escaping (Result<User, Error>) -> Void) {
        do {
            print("Saving image", image)
            self.savingImage = true
            let idToken: String? = self.authorization?.idToken
            URLSession.shared.postImage(for: try self.imageUrl(), for: image, for: "Bearer \(idToken!)") { (result: Result<User, Error>) in
                switch result {
                case .success(let user):
                    self.user = user
                    callback(.success(user))
                case .failure(let error):
                    callback(.failure(error))
                }
                self.savingImage = false
            }
        } catch(let error) {
            print("Failed to save user", error)
            callback(.failure(error))
        }
    }
    
    func verifyPhone(callback: @escaping (Result<VerifyPhoneResponse, Error>) -> Void) {
        do {
            self.saving = true
            let idToken: String? = self.authorization?.idToken
            let accessToken: String? = self.authorization?.accessToken
            URLSession.shared.postData(for: try self.verifyPhoneUrl(), for: "Bearer \(idToken!)", for: accessToken!) { (result: Result<VerifyPhoneResponse, Error>) in
                switch result {
                case .success(let response):
                    callback(.success(response))
                case .failure(let error):
                    callback(.failure(error))
                }
                self.saving = false
            }
        } catch(let error) {
            print("Failed to send phone verification", error)
            callback(.failure(error))
        }
    }
    
    func confirmPhone(code: String, callback: @escaping (Result<ConfirmPhoneResponse, Error>) -> Void) {
        do {
            self.saving = true
            let idToken: String? = self.authorization?.idToken
            let accessToken: String? = self.authorization?.accessToken
            URLSession.shared.postData(for: try self.confirmPhoneUrl(code: code), for: "Bearer \(idToken!)", for: accessToken!) { (result: Result<ConfirmPhoneResponse, Error>) in
                switch result {
                case .success(let response):
                    callback(.success(response))
                case .failure(let error):
                    callback(.failure(error))
                }
                self.saving = false
            }
        } catch(let error) {
            print("Failed to send phone verification", error)
            callback(.failure(error))
        }
    }
    
    struct PatchRequest: Encodable {
        var firstName: String
        var lastName: String
    }
    
    struct CompleteOnboardingRequest: Encodable {
        var onboardingCompleted: Bool
    }
    
    struct VerifyPhoneResponse: Decodable {
        var CodeDeliveryDetails: CodeDeliveryDetails
    }
    
    struct ConfirmPhoneResponse: Decodable {
        
    }
    
    struct CodeDeliveryDetails: Decodable {
        var Destination: String
        var DeliveryMedium: String
        var AttributeName: String
    }
}
