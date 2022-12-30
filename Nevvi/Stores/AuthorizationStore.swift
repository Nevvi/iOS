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
    
    enum BiometricType {
        case none
        case touch
        case face
    }
    
    enum AuthorizationError: Error, LocalizedError, Identifiable {
        case invalidCredentials
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
                return NSLocalizedString("Invalid credentials", comment: "")
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
    
    func login(email: String, password: String, callback: @escaping (Result<Authorization, AuthorizationError>) -> Void) {
        do {
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
}
