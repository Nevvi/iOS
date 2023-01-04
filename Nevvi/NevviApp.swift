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
    @StateObject private var connectionStore = ConnectionStore()
    @StateObject private var connectionsStore = ConnectionsStore()
    @StateObject private var usersStore = UsersStore()
    
    var body: some Scene {
        WindowGroup {
            if (self.authStore.authorization != nil) {
                ContentView(connectionStore: self.connectionStore,
                            connectionsStore: self.connectionsStore,
                            usersStore: self.usersStore)
                    .environmentObject(accountStore)
                    .environmentObject(authStore)
            } else {
                Login(authStore: authStore) { (auth: Authorization) in
                    // hacky way of restoring auth on login
                    self.accountStore.authorization = auth
                    self.connectionStore.authorization = auth
                    self.connectionsStore.authorization = auth
                    self.usersStore.authorization = auth
                }
            }
        }
    }
}
