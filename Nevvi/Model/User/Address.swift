//
//  Address.swift
//  Nevvi
//
//  Created by Tyler Cobb on 12/29/22.
//

import Foundation

struct Address: Hashable, Codable {
    var street: String?
    var unit: String?
    var city: String?
    var state: String?
    var zipCode: Int?
}
