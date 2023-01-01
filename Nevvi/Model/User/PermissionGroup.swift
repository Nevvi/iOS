//
//  PermissionGroup.swift
//  Nevvi
//
//  Created by Tyler Cobb on 12/29/22.
//

import Foundation

struct PermissionGroup: Hashable, Codable {
    var name: String
    var fields: [String]
}
