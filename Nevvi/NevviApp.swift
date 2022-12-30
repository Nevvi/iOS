//
//  NevviApp.swift
//  Nevvi
//
//  Created by Tyler Cobb on 12/29/22.
//

import SwiftUI

@main
struct NevviApp: App {
    @StateObject private var modelData = ModelData()
    @StateObject private var authStore = AuthorizationStore()
    @StateObject private var accountStore = AccountStore()
    
    var body: some Scene {
        WindowGroup {
            if (self.authStore.authorization != nil) {
                ContentView(accountStore: self.accountStore)
                    .environmentObject(modelData)
            } else {
                Login(authStore: authStore) { (auth: Authorization) in
                    // hacky way of restoring auth on login
                    self.accountStore.authorization = auth
                }
            }
        }
    }
}
