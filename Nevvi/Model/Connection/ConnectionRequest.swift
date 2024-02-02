//
//  ConnectionRequest.swift
//  Nevvi
//
//  Created by Tyler Cobb on 12/31/22.
//

import Foundation

struct ConnectionRequest: Hashable, Codable {
    var requestingUserId: String
    var requestedUserId: String
    var requesterFirstName: String
    var requesterLastName: String
    var requestingPermissionGroupName: String
    var requesterImage: String
}
