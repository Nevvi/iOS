//
//  AuthorizationStore.swift
//  Nevvi
//
//  Created by Tyler Cobb on 12/29/22.
//

import Foundation

class AuthorizationStore: ObservableObject {
    
    @Published var authorization: Authorization? = nil
    
    private func fileURL() throws -> URL {
        try FileManager.default
            .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent("authorization.data")
    }
    
    private func loginUrl() throws -> URL {
        return URL(string: "https://api.development.nevvi.net/authentication/v1/login")!
    }
    
    func login(email: String, password: String, callback: @escaping (Result<Authorization, Error>) -> Void) {
        do {
            let request = LoginRequest(username: email.lowercased(), password: password)
            URLSession.shared.postData(for: try self.loginUrl(), for: request) { (result: Result<Authorization, Error>) in
                switch result {
                case .success(let authorization):
                    self.save(authorization: authorization)
                    callback(.success(authorization))
                case .failure(let error):
                    callback(.failure(error))
                }
            }
        } catch(let error) {
            callback(.failure(error))
        }
    }
    
    func load() {
        do {
            let fileURL = try self.fileURL()
            print(fileURL)
            guard let file = try? FileHandle(forReadingFrom: fileURL) else {
                return
            }
            let authorization = try JSONDecoder().decode(Authorization.self, from: file.availableData)
            self.authorization = authorization
        } catch {
            print("Failed to load authorization data")
        }
    }
    
    func save(authorization: Authorization) {
        do {
            let data = try JSONEncoder().encode(authorization)
            let outfile = try self.fileURL()
            try data.write(to: outfile)
            self.authorization = authorization
        } catch {
            print("Failed to save authorization data")
        }
    }

    struct LoginRequest: Encodable {
        var username: String
        var password: String
    }
}
