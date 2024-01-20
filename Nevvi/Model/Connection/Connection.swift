//
//  Connection.swift
//  Nevvi
//
//  Created by Tyler Cobb on 12/29/22.
//

import Foundation
import SwiftUI
import CoreLocation

struct Connection: Hashable, Codable, Identifiable {
    var id: String
    var firstName: String
    var lastName: String
    var bio: String?
    var email: String?
    var phoneNumber: String?
    var birthday: Date?
    var address: Address?
    var mailingAddress: Address?
    var profileImage: String
    var permissionGroup: String?
    var connected: Bool?
    var requested: Bool?
    var inSync: Bool?
    
    var birthdayStr: String? {
        guard let birthday = self.birthday else {
            return nil
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: birthday)
    }
}
