//
//  User.swift
//  Nevvi
//
//  Created by Tyler Cobb on 12/29/22.
//

import Foundation
import SwiftUI
import CoreLocation

struct User: Hashable, Codable {
    var id: String
    var firstName: String?
    var lastName: String?
    var email: String
    var emailConfirmed: Bool
    var phoneNumber: String?
    var phoneNumberConfirmed: Bool?
    var birthday: String?
    var onboardingCompleted: Bool
    var blockedUsers: [String]
    var address: Address
    var permissionGroups: [PermissionGroup]
    var profileImage: String
}
