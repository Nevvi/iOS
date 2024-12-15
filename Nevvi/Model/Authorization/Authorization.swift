//
//  Authorization.swift
//  Nevvi
//
//  Created by Tyler Cobb on 12/29/22.
//

import Foundation
import JWTDecode

class Authorization {
    private var idTokenJwt: JWT
    private var accessTokenJwt: JWT
    private var refreshToken: String
    
    var idToken: String {
        if idTokenJwt.expired {
            // TODO - refresh tokens on the fly
            // self.refresh()
        }
        
        return idTokenJwt.string
    }
    
    var accessToken: String {
        if !accessTokenJwt.expired {
            // TODO - refresh tokens on the fly
            // self.refresh()
        }
        
        return accessTokenJwt.string
    }
    
    var isExpired : Bool {
        return idTokenJwt.expired || accessTokenJwt.expired
    }
    
    var id: String

    init(idToken: String, accessToken: String, refreshToken: String, id: String) throws {
        self.id = id
        self.idTokenJwt = try decode(jwt: idToken)
        self.accessTokenJwt = try decode(jwt: accessToken)
        self.refreshToken = refreshToken
    }
    
    private func refreshUrl() throws -> URL {
        return URL(string: "\(BuildConfiguration.shared.baseURL)/authentication/v1/refreshLogin")!
    }
    
    private func refresh() -> Void {
        do {
            print("Refreshing tokens")
                        
            var request = URLRequest(url: try refreshUrl())
            request.httpMethod = "POST"
            request.setValue(refreshToken, forHTTPHeaderField: "RefreshToken")
            
            // TODO - how to do this while blocking?
            URLSession.shared.execute(request: request) { (result: Result<RefreshResponse, Error>) in
                switch result {
                case .success(let response):
                    do {
                        self.idTokenJwt = try decode(jwt: response.idToken)
                        self.accessTokenJwt = try decode(jwt: response.accessToken)
                        print("Done refreshing tokens")
                    } catch {
                        // TODO - go back to login page
                        print("Failed to decode refreshed JWT: \(error.localizedDescription)")
                    }
                case .failure(let error):
                    print(error)
                    // TODO - go back to login page
                }
            }
        } catch(let error) {
            print(error)
            // TODO - go back to login page
        }
    }
}

struct RefreshResponse: Decodable {
    var idToken: String
    var accessToken: String
}
