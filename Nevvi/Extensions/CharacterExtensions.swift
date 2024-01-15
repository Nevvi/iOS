//
//  CharacterExtensions.swift
//  Nevvi
//
//  Created by Tyler Standal on 1/15/24.
//

import Foundation

extension Character {
    var isUppercase: Bool { return String(self).uppercased() == String(self) }
}
