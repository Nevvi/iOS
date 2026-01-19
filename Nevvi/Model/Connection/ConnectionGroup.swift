//
//  Connection.swift
//  Nevvi
//
//  Created by Tyler Cobb on 12/29/22.
//

import Foundation

struct ConnectionGroup: Hashable, Codable, Identifiable {
    var id: String
    var userId: String
    var name: String
    var connections: [String]
    var invites: [String]
}
