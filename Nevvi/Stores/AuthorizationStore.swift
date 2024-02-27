//
//  AuthorizationStore.swift
//  Nevvi
//
//  Created by Tyler Cobb on 12/29/22.
//

import Foundation
import SwiftUI
import LocalAuthentication

class AuthorizationStore: ObservableObject {
    
    @Published var authorization: Authorization? = nil
    
    @Published var loggingIn: Bool = false
    @Published var loggingOut: Bool = false
    @Published var signingUp: Bool = false
    @Published var confirming: Bool = false
    @Published var sendingResetCode: Bool = false
    @Published var resettingPassword: Bool = false
    
    enum BiometricType {
        case none
        case touch
        case face
    }
    
    enum AuthorizationError: Error, LocalizedError, Identifiable {
        case invalidCredentials
        case invalidSignup
        case invalidConfirmation
        case deniedAccess
        case noFaceIdEnrolled
        case noFingerPrintEnrolled
        case biometricError
        case credentialsNotSaved
        case passwordResetRequired
        case unknown
        
        var id: String {
            self.localizedDescription
        }
        
        var errorDescription: String? {
            switch self {
            case .invalidCredentials:
                return NSLocalizedString("Either the username or password you entered is incorrect. Please try again.", comment: "")
            case .invalidSignup:
                return NSLocalizedString("Invalid credentials for signup", comment: "")
            case .invalidConfirmation:
                return NSLocalizedString("Invalid confirmation code. Please try again.", comment: "")
            case .deniedAccess:
                return NSLocalizedString("You have denied access. Turn on Face ID in app settings", comment: "")
            case .noFaceIdEnrolled:
                return NSLocalizedString("You have not registered Face ID yet", comment: "")
            case .noFingerPrintEnrolled:
                return NSLocalizedString("You have not regiestered any fingerprint yet", comment: "")
            case .biometricError:
                return NSLocalizedString("Biometric access not recognized", comment: "")
            case .credentialsNotSaved:
                return NSLocalizedString("No login credentials have been saved. Face ID will be enabled after the first successful login.", comment: "")
            case .passwordResetRequired:
                return NSLocalizedString("Password reset required", comment: "")
            case .unknown:
                return NSLocalizedString("Unknown error occurred", comment: "")
            }
        }
    }
    
    func biometricType() -> BiometricType {
        let authContext = LAContext()
        let _ = authContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
        switch authContext.biometryType {
        case .none:
            return BiometricType.none
        case .faceID:
            return BiometricType.face
        case .touchID:
            return BiometricType.touch
        @unknown default:
            return BiometricType.none
        }
    }
    
    func requestBiometricUnlock(completion: @escaping (Result<Credentials, AuthorizationError>) -> Void) {
        let authContext = LAContext()
        
        var error: NSError?
        let canEvaluate = authContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
        
        if let error = error {
            switch error.code {
            case -6:
                completion(.failure(.deniedAccess))
            case -7:
                if authContext.biometryType == .faceID {
                    completion(.failure(.noFaceIdEnrolled))
                } else {
                    completion(.failure(.noFingerPrintEnrolled))
                }
            default:
                completion(.failure(.biometricError))
            }
        }
        
        if canEvaluate {
            if authContext.biometryType != .none {
                authContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Need to access credentials") { success, error in
                    DispatchQueue.main.async {
                        if error != nil {
                            completion(.failure(.biometricError))
                        } else {
                            let credentials = KeychainStore.getCredentials()
                            guard let credentials = credentials else {
                                completion(.failure(.credentialsNotSaved))
                                return
                            }
                            completion(.success(credentials))
                        }
                    }
                }
            }
        }
    }
    
    private func minVersionsUrl() throws -> URL {
        return URL(string: "\(BuildConfiguration.shared.baseURL)/authentication/v1/versions")!
    }
    
    private func loginUrl() throws -> URL {
        return URL(string: "\(BuildConfiguration.shared.baseURL)/authentication/v1/login")!
    }
    
    private func logoutUrl() throws -> URL {
        return URL(string: "\(BuildConfiguration.shared.baseURL)/authentication/v1/logout")!
    }
    
    private func signupUrl() throws -> URL {
        return URL(string: "\(BuildConfiguration.shared.baseURL)/authentication/v1/register")!
    }
    
    private func confirmUrl() throws -> URL {
        return URL(string: "\(BuildConfiguration.shared.baseURL)/authentication/v1/confirm")!
    }
    
    private func forgotPasswordUrl() throws -> URL {
        return URL(string: "\(BuildConfiguration.shared.baseURL)/authentication/v1/forgotPassword")!
    }
    
    private func confirmForgotPasswordUrl() throws -> URL {
        return URL(string: "\(BuildConfiguration.shared.baseURL)/authentication/v1/confirmForgotPassword")!
    }
    
    func getMinAppVersion(callback: @escaping (String) -> Void) {
        do {
            URLSession.shared.fetchData(for: try self.minVersionsUrl()) { (result: Result<MinVersionResponse, Error>) in
                switch result {
                case .success(let response):
                    callback(response.ios)
                case .failure(let error):
                    // Do something catastrophic here?
                    print(error)
                }
            }
        } catch(let error) {
            print(error)
        }
    }
    
    func login(username: String, password: String, callback: @escaping (Result<Authorization, AuthorizationError>) -> Void) {
        do {
            print("Logging in")
            self.loggingIn = true
            let request = Credentials(username: username, password: password)
            URLSession.shared.postData(for: try self.loginUrl(), for: request) { (result: Result<Authorization, Error>) in
                switch result {
                case .success(let authorization):
                    self.authorization = authorization
                    callback(.success(authorization))
                case .failure(let error):
                    print(error)
                    let httpError = error as? HttpError
                    if httpError == HttpError.passwordResetError {
                        callback(.failure(AuthorizationError.passwordResetRequired))
                    } else {
                        callback(.failure(AuthorizationError.invalidCredentials))
                    }
                }
                self.loggingIn = false
            }
        } catch(let error) {
            print(error)
            callback(.failure(AuthorizationError.unknown))
            self.loggingIn = false
        }
    }
    
    func logout(callback: @escaping (Result<Bool, Error>) -> Void) {
        do {
            print("Logging out")
            if (self.authorization == nil) {
                return
            }
            
            self.loggingOut = true
            
            let idToken = self.authorization!.idToken
            let accessToken = self.authorization!.accessToken
            
            URLSession.shared.postData(for: try self.logoutUrl(), for: idToken, for: accessToken) { (result: Result<LogoutResponse, Error>) in
                switch result {
                case .success(_):
                    self.authorization = nil
                    callback(.success(true))
                case .failure(let error):
                    callback(.failure(error))
                }
                self.loggingOut = false
            }
        } catch(let error) {
            callback(.failure(error))
            self.loggingOut = false
        }
    }
    
    func signUp(username: String, password: String, callback: @escaping (Result<SignupResponse, AuthorizationError>) -> Void) {
        do {
            self.signingUp = true
            let request = SignupRequest(username: username, password: password)
            URLSession.shared.postData(for: try self.signupUrl(), for: request) { (result: Result<SignupResponse, Error>) in
                switch result {
                case .success(let response):
                    callback(.success(response))
                case .failure(let error):
                    print(error)
                    callback(.failure(AuthorizationError.invalidSignup))
                }
                self.signingUp = false
            }
        } catch(let error) {
            print(error)
            callback(.failure(AuthorizationError.unknown))
            self.signingUp = false
        }
    }
    
    func confirmAccount(username: String, code: String, callback: @escaping (Result<ConfirmResponse, AuthorizationError>) -> Void) {
        do {
            self.confirming = true
            let request = ConfirmRequest(username: username, confirmationCode: code)
            URLSession.shared.postData(for: try self.confirmUrl(), for: request) { (result: Result<ConfirmResponse, Error>) in
                switch result {
                case .success(let response):
                    callback(.success(response))
                case .failure(let error):
                    print(error)
                    callback(.failure(AuthorizationError.invalidConfirmation))
                }
                self.confirming = false
            }
        } catch(let error) {
            print(error)
            callback(.failure(AuthorizationError.unknown))
            self.confirming = false
        }
    }
    
    func forgotPassword(username: String, callback: @escaping (Result<ConfirmResponse, AuthorizationError>) -> Void) {
        do {
            self.sendingResetCode = true
            let request = ForgotPasswordRequest(username: username)
            URLSession.shared.postData(for: try self.forgotPasswordUrl(), for: request) { (result: Result<ConfirmResponse, Error>) in
                switch result {
                case .success(let response):
                    callback(.success(response))
                case .failure(let error):
                    print(error)
                    callback(.failure(AuthorizationError.unknown))
                }
                self.sendingResetCode = false
            }
        } catch(let error) {
            print(error)
            callback(.failure(AuthorizationError.unknown))
            self.sendingResetCode = false
        }
    }
    
    func confirmForgotPassword(username: String, code: String, password: String, callback: @escaping (Result<ConfirmResponse, AuthorizationError>) -> Void) {
        do {
            self.resettingPassword = true
            let request = ConfirmForgotPasswordRequest(username: username, code: code, password: password)
            URLSession.shared.postData(for: try self.confirmForgotPasswordUrl(), for: request) { (result: Result<ConfirmResponse, Error>) in
                switch result {
                case .success(let response):
                    callback(.success(response))
                case .failure(let error):
                    print(error)
                    callback(.failure(AuthorizationError.invalidConfirmation))
                }
                self.resettingPassword = false
            }
        } catch(let error) {
            print(error)
            callback(.failure(AuthorizationError.unknown))
            self.resettingPassword = false
        }
    }
    
    struct SignupRequest: Encodable {
        var username: String
        var password: String
    }
    
    struct SignupResponse: Decodable {
        var id: String
        var isConfirmed: Bool
        var codeDeliveryDestination: String
        var codeDeliveryMedium: String
        var codeDeliveryAttribute: String
    }
    
    struct ConfirmRequest: Encodable {
        var username: String
        var confirmationCode: String
    }
    
    struct ForgotPasswordRequest: Encodable {
        var username: String
    }
    
    struct ConfirmForgotPasswordRequest: Encodable {
        var username: String
        var code: String
        var password: String
    }
    
    struct ConfirmResponse: Decodable {
        
    }
    
    struct LogoutResponse: Decodable {
        
    }
    
    struct MinVersionResponse: Decodable {
        var ios: String
    }
}
