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
        if (!accountStore.id.isEmpty) {
            if (accountStore.onboardingCompleted) {
                TabView {
                    RefreshableView(onRefresh: {
                        self.connectionsStore.load()
                    }, view: ConnectionList(connectionsStore: self.connectionsStore, connectionStore: self.connectionStore).tabItem() {
                        Image(systemName: "person.3.fill")
                        Text("Connections")
                    }).onAppear {
                        self.connectionsStore.load()
                    }
                    
                    RefreshableView(onRefresh: {
                        self.connectionsStore.loadRequests()
                    }, view: ConnectionRequestList(accountStore: self.accountStore, connectionsStore: self.connectionsStore).tabItem() {
                        Image(systemName: "person.fill.questionmark")
                        Text("Requests")
                    }).onAppear {
                        self.connectionsStore.loadRequests()
                    }
                    
                    ConnectionSearch(accountStore: self.accountStore, usersStore: self.usersStore).tabItem() {
                        Image(systemName: "magnifyingglass")
                        Text("Search")
                    }
                    
                    RefreshableView(onRefresh: {
                        self.accountStore.load()
                    }, view: Account(accountStore: self.accountStore).tabItem() {
                        Image(systemName: "person.fill")
                        Text("Account")
                    })
                }
            } else {
                OnboardingCarousel(accountStore: self.accountStore)
            }
        } else {
            // TODO - better loading view
            ProgressView().onAppear {
                self.accountStore.load()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static let modelData = ModelData()
    static var previews: some View {
        ContentView(accountStore: AccountStore(user: modelData.user),
                    connectionStore: ConnectionStore(connection: modelData.connection),
                    connectionsStore: ConnectionsStore(connections: modelData.connectionResponse.users, requests: modelData.requests),
                    usersStore: UsersStore(users: modelData.connectionResponse.users)
        ).environmentObject(modelData)
    }
}
