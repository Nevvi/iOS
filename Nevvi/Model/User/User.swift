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
    var bio: String?
    var email: String?
    var emailConfirmed: Bool?
    var phoneNumber: String
    var phoneNumberConfirmed: Bool
    var onboardingCompleted: Bool
    var deviceId: String?
    var address: Address
    var mailingAddress: Address
    var birthday: Date?
    var blockedUsers: [String]
    var permissionGroups: [PermissionGroup]
    var profileImage: String
    var deviceSettings: DeviceSettings
}
