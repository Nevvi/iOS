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
    var deviceId: String?
    var email: String?
    var emailConfirmed: Bool?
    var phoneNumber: String
    var phoneNumberConfirmed: Bool
    var birthday: Date?
    var onboardingCompleted: Bool
    var blockedUsers: [String]
    var address: Address
    var mailingAddress: Address
    var permissionGroups: [PermissionGroup]
    var profileImage: String
    var deviceSettings: DeviceSettings
    var bio: String?
}
