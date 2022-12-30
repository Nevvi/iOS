//
//  Credentials.swift
//  Nevvi
//
//  Created by Tyler Cobb on 12/29/22.
//

import Foundation

struct Credentials: Codable {
    var username: String
    var password: String
    
    func encoded() -> String {
        let encoder = JSONEncoder()
        let credentialsData = try! encoder.encode(self)
        return String(data: credentialsData, encoding: .utf8)!
    }
    
    static func decode(_ credentialsData: String) -> Credentials {
        let decoder = JSONDecoder()
        let jsonData = credentialsData.data(using: .utf8)
        return try! decoder.decode((Credentials.self), from: jsonData!)
    }
}
