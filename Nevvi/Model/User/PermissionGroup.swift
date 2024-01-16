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
    
    func copy() -> PermissionGroup {
        return PermissionGroup(name: self.name, fields: self.fields)
    }
    
    mutating func addField(fieldToAdd: String) {
        if self.fields.contains(fieldToAdd) {
            return
        }
        
        self.fields.append(fieldToAdd)
    }
    
    mutating func removeField(fieldToRemove: String) {
        self.fields.removeAll(where: { field in
            field == fieldToRemove
        })
    }
}
