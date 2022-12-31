//
//  ConnectionsResponse.swift
//  Nevvi
//
//  Created by Tyler Cobb on 12/31/22.
//

import Foundation

struct ConnectionResponse : Decodable {
    var users: [Connection]
    var count: Int
}
