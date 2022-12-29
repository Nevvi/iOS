//
//  ContentView.swift
//  Nevvi
//
//  Created by Tyler Cobb on 12/29/22.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var authStore: AuthorizationStore
    @ObservedObject var accountStore: AccountStore
    
    var body: some View {
        if (authStore.authorization != nil && accountStore.user != nil) {
            TabView {
                Account(user: accountStore.user!).tabItem() {
                    Image(systemName: "person.fill")
                    Text("Account")
                }
                ConnectionList().tabItem() {
                    Image(systemName: "person.3.fill")
                    Text("Connections")
                }
            }
        } else if (authStore.authorization != nil) {
            // TODO - better loading view
            ProgressView().onAppear(perform: self.accountStore.load)
        } else {
            Login(authStore: authStore) { (auth: Authorization) in
                // hacky way of restoring auth on login
                self.accountStore.authorization = auth
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(
            authStore: AuthorizationStore(), accountStore: AccountStore()
        ).environmentObject(ModelData())
    }
}
