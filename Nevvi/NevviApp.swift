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
    @StateObject private var connectionGroupStore = ConnectionGroupStore()
    @StateObject private var connectionGroupsStore = ConnectionGroupsStore()
    @StateObject private var usersStore = UsersStore()
    private var contactStore = ContactStore()
    
    var body: some Scene {
        WindowGroup {
            if (self.authStore.authorization != nil) {
                ContentView(connectionStore: self.connectionStore, connectionGroupStore: self.connectionGroupStore)
                    .environmentObject(accountStore)
                    .environmentObject(authStore)
                    .environmentObject(connectionsStore)
                    .environmentObject(connectionGroupsStore)
                    .environmentObject(usersStore)
            } else {
                Login(authStore: authStore) { (auth: Authorization) in
                    // hacky way of restoring auth on login
                    self.accountStore.authorization = auth
                    self.connectionStore.authorization = auth
                    self.connectionsStore.authorization = auth
                    self.connectionGroupStore.authorization = auth
                    self.connectionGroupsStore.authorization = auth
                    self.usersStore.authorization = auth
                    
                    // Greedy solution is temporary for now until more granular data is sent
                    self.contactStore.authorization = auth
                    self.contactStore.syncAllContacts()
                }
            }
        }
    }
}
