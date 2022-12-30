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
    @Published var signingUp: Bool = false
    @Published var confirming: Bool = false
    
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
        case unknown
        
        var id: String {
            self.localizedDescription
        }
        
        var errorDescription: String? {
            switch self {
            case .invalidCredentials:
                return NSLocalizedString("Either the email or password you entered is incorrect. Please try again.", comment: "")
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
                return NSLocalizedString("No biometric credentials saved. Would you like to saved them?", comment: "")
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
        
        let credentials = KeychainStore.getCredentials()
        guard let credentials = credentials else {
            completion(.failure(.credentialsNotSaved))
            return
        }
        
        var error: NSError?
        let canEvaluate = authContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
        
        if let error = error {
            print(error.code)
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
                            completion(.success(credentials))
                        }
                    }
                }
            }
        }
    }
    
    private func loginUrl() throws -> URL {
        return URL(string: "https://api.development.nevvi.net/authentication/v1/login")!
    }
    
    private func signupUrl() throws -> URL {
        return URL(string: "https://api.development.nevvi.net/authentication/v1/register")!
    }
    
    private func confirmUrl() throws -> URL {
        return URL(string: "https://api.development.nevvi.net/authentication/v1/confirm")!
    }
    
    func login(email: String, password: String, callback: @escaping (Result<Authorization, AuthorizationError>) -> Void) {
        do {
            print("Logging in")
            self.loggingIn = true
            let request = Credentials(username: email.lowercased(), password: password)
            URLSession.shared.postData(for: try self.loginUrl(), for: request) { (result: Result<Authorization, Error>) in
                switch result {
                case .success(let authorization):
                    self.authorization = authorization
                    callback(.success(authorization))
                case .failure(let error):
                    print(error)
                    callback(.failure(AuthorizationError.invalidCredentials))
                }
                self.loggingIn = false
            }
        } catch(let error) {
            print(error)
            callback(.failure(AuthorizationError.unknown))
        }
    }
    
    func signUp(email: String, password: String, callback: @escaping (Result<SignupResponse, AuthorizationError>) -> Void) {
        do {
            self.signingUp = true
            let request = SignupRequest(email: email.lowercased(), password: password)
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
        }
    }
    
    func confirmAccount(email: String, code: String, callback: @escaping (Result<ConfirmResponse, AuthorizationError>) -> Void) {
        do {
            self.confirming = true
            let request = ConfirmRequest(username: email.lowercased(), confirmationCode: code)
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
        }
    }
    
    struct SignupRequest: Encodable {
        var email: String
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
    
    struct ConfirmResponse: Decodable {
        
    }
}
