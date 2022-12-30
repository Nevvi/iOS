//
//  KeychainStore.swift
//  Nevvi
//
//  Created by Tyler Cobb on 12/29/22.
//

import Foundation
import SwiftKeychainWrapper

enum KeychainStore {
    static let credentialsKey = "credentials"
    
    static func getCredentials() -> Credentials? {
        if let myCredentialsString = KeychainWrapper.standard.string(forKey: self.credentialsKey) {
            return Credentials.decode(myCredentialsString)
        } else {
            return nil
        }
    }
    
    static func saveCredentials(_ credentials: Credentials) -> Bool {
        if KeychainWrapper.standard.set(credentials.encoded(), forKey: self.credentialsKey) {
            return true
        } else {
            return false
        }
    }
}
