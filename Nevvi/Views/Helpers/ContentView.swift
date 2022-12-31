//
//  ContentView.swift
//  Nevvi
//
//  Created by Tyler Cobb on 12/29/22.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var accountStore: AccountStore
    @ObservedObject var connectionStore: ConnectionStore
    @ObservedObject var connectionsStore: ConnectionsStore
    @ObservedObject var usersStore: UsersStore
    
    var body: some View {
        if (accountStore.user != nil) {
            if (accountStore.user!.onboardingCompleted) {
                TabView {
                    ConnectionList(connections: self.connectionsStore.connections, connectionStore: self.connectionStore).tabItem() {
                        Image(systemName: "person.3.fill")
                        Text("Connections")
                    }
                    
                    ConnectionRequestList(accountStore: self.accountStore, requests: self.connectionsStore.requests).tabItem() {
                        Image(systemName: "person.fill.questionmark")
                        Text("Requests")
                    }
                    
                    ConnectionSearch(accountStore: self.accountStore, usersStore: self.usersStore).tabItem() {
                        Image(systemName: "magnifyingglass")
                        Text("Search")
                    }
                    
                    Account(accountStore: self.accountStore, user: accountStore.user!).tabItem() {
                        Image(systemName: "person.fill")
                        Text("Account")
                    }
                }
            } else {
                OnboardingCarousel(accountStore: self.accountStore)
            }
        } else {
            // TODO - better loading view
            ProgressView().onAppear {
                // TODO - race condition where account is loaded first
                self.connectionsStore.load()
                self.connectionsStore.loadRequests()
                self.accountStore.load()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static let modelData = ModelData()
    static var previews: some View {
        ContentView(accountStore: AccountStore(),
                    connectionStore: ConnectionStore(),
                    connectionsStore: ConnectionsStore(),
                    usersStore: UsersStore()
        ).environmentObject(modelData)
    }
}
