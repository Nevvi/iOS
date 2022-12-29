//
//  Authorization.swift
//  Nevvi
//
//  Created by Tyler Cobb on 12/29/22.
//

import Foundation

class Authorization: Codable {
    var idToken: String
    var accessToken: String
    var refreshToken: String
    var id: String

    init(idToken: String, accessToken: String, refreshToken: String, id: String) {
        self.idToken = idToken
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.id = id
    }
}
