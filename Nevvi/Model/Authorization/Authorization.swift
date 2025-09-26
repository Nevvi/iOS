//
//  Authorization.swift
//  Nevvi
//
//  Created by Tyler Cobb on 12/29/22.
//

import Foundation
import JWTDecode

class Authorization: ObservableObject, Equatable {
    private var idTokenJwt: JWT
    private var accessTokenJwt: JWT
    private var refreshToken: String
    
    // Callback for when authorization fails and user needs to log out
    var onAuthorizationFailed: (() -> Void)?
    
    var idToken: String {
        return idTokenJwt.string
    }
    
    var accessToken: String {
        return accessTokenJwt.string
    }
    
    var isExpired: Bool {
        return idTokenJwt.expired
    }
    
    let id: String

    init(idToken: String, accessToken: String, refreshToken: String, id: String) throws {
        self.id = id
        self.idTokenJwt = try decode(jwt: idToken)
        self.accessTokenJwt = try decode(jwt: accessToken)
        self.refreshToken = refreshToken
    }
    
    func getValidToken() -> String? {
        if isExpired {
            print("Tokens are expired - calling onAuthorizationFailed")
            onAuthorizationFailed?()
            return nil
        }
        return idToken
    }
    
    // MARK: - Equatable
    static func == (lhs: Authorization, rhs: Authorization) -> Bool {
        return lhs.id == rhs.id && 
               lhs.idToken == rhs.idToken && 
               lhs.accessToken == rhs.accessToken
    }
}

enum AuthorizationError: Error, LocalizedError, Equatable {
    case tokenExpired
    case sessionEnded
    
    var errorDescription: String? {
        switch self {
        case .tokenExpired:
            return "Session expired. Please log in again."
        case .sessionEnded:
            return nil // Don't show error message for graceful logout
        }
    }
}

struct RefreshResponse: Decodable {
    var idToken: String
    var accessToken: String
}
