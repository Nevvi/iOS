//
//  ContentView.swift
//  Nevvi
//
//  Created by Tyler Cobb on 12/29/22.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var accountStore: AccountStore
    @EnvironmentObject var connectionsStore: ConnectionsStore
    @EnvironmentObject var usersStore: UsersStore
    
    @ObservedObject var connectionStore: ConnectionStore
    
    var body: some View {
        if (!accountStore.id.isEmpty) {
            if (accountStore.onboardingCompleted) {
                TabView {
                    RefreshableView(onRefresh: {
                        self.connectionsStore.load()
                    }, view: ConnectionList(connectionStore: self.connectionStore).tabItem() {
                        Image(systemName: "person.line.dotted.person.fill")
                        Text("Connections")
                    })
                    
                    RefreshableView(onRefresh: {
                        self.connectionsStore.loadRequests()
                    }, view: ConnectionRequestList().tabItem() {
                        Image(systemName: "person.fill.questionmark")
                        Text("Requests")
                    })
                    
                    RefreshableView(onRefresh: {
                        
                    }, view: Text("Groups").tabItem() {
                        Image(systemName: "person.3.fill")
                        Text("Groups")
                    })
                    
                    RefreshableView(onRefresh: {
                        self.accountStore.load()
                        self.connectionsStore.loadRejectedUsers()
                    }, view: Account().tabItem() {
                        Image(systemName: "person.fill")
                        Text("Account")
                    })
                }
            } else {
                OnboardingCarousel()
            }
        } else {
            // TODO - better loading view
            ProgressView().onAppear {
                self.accountStore.load()
                self.connectionsStore.load()
                self.connectionsStore.loadRequests()
                self.connectionsStore.loadRejectedUsers()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static let modelData = ModelData()
    static var previews: some View {
        ContentView(connectionStore: ConnectionStore(connection: modelData.connection))
        .environmentObject(AccountStore(user: modelData.user))
        .environmentObject(ConnectionsStore(connections: modelData.connectionResponse.users,
                                            requests: modelData.requests,
                                            blockedUsers: modelData.connectionResponse.users))
        .environmentObject(AuthorizationStore())
        .environmentObject(UsersStore(users: modelData.connectionResponse.users))
    }
}
