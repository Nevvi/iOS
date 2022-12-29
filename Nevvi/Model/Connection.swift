//
//  Connection.swift
//  Nevvi
//
//  Created by Tyler Cobb on 12/29/22.
//

import Foundation
import SwiftUI
import CoreLocation

struct Connection: Hashable, Codable {
    var id: String
    var firstName: String
    var lastName: String
    var email: String?
    var phoneNumber: String?
    var birthday: String?
    var address: Address?
    

    private var profileImage: String
    var image: Image {
        Image(profileImage)
    }
}
