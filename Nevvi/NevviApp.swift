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
            ContentView(
                authStore: authStore,
                accountStore: accountStore
            )
            .environmentObject(modelData)
            .onAppear {
                // hacky way of restoring auth on app load
                authStore.load()
                accountStore.authorization = authStore.authorization
             }
        }
    }
}
