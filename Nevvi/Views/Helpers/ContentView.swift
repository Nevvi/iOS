//
//  ContentView.swift
//  Nevvi
//
//  Created by Tyler Cobb on 12/29/22.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.scenePhase) var scenePhase
    
    @EnvironmentObject var accountStore: AccountStore
    @EnvironmentObject var connectionsStore: ConnectionsStore
    @EnvironmentObject var connectionGroupsStore: ConnectionGroupsStore
    @EnvironmentObject var usersStore: UsersStore
    @EnvironmentObject var contactStore: ContactStore
    
    @ObservedObject var connectionStore: ConnectionStore
    @ObservedObject var connectionGroupStore: ConnectionGroupStore
    
    var body: some View {
        if (!accountStore.id.isEmpty) {
            if (accountStore.onboardingCompleted) {
                TabView {
                    ConnectionList(connectionStore: self.connectionStore)
                        .tabItem() {
                            Label("Connections", systemImage: "person.line.dotted.person.fill")
                        }
                    
                    ConnectionRequestList()
                        .tabItem() {
                            Label("Requests", systemImage: "person.fill.questionmark")
                        }
                    
                    ConnectionGroupList(connectionGroupStore: self.connectionGroupStore, connectionStore: self.connectionStore)
                        .tabItem() {
                            Label("Groups", systemImage: "person.3.fill")
                        }
                    
                    Account()
                        .tabItem() {
                            Label("Account", systemImage: "person.fill")
                        }
                }
                .errorAlert(error: self.$accountStore.error)
                .errorAlert(error: self.$connectionStore.error)
                .errorAlert(error: self.$connectionsStore.error)
                .errorAlert(error: self.$connectionGroupStore.error)
                .errorAlert(error: self.$connectionGroupsStore.error)
                .errorAlert(error: self.$usersStore.error)
                .onChange(of: scenePhase) { newPhase in
                    if newPhase == .active {
                        self.reload()
                    } 
                }
            } else {
                OnboardingCarousel()
            }
        } else {
            // TODO - better loading view
            ProgressView().onAppear {
                self.reload()
            }
        }
    }
    
    func reload() {
        self.accountStore.load()
        self.connectionsStore.load()
        self.connectionsStore.loadRequests()
        self.connectionsStore.loadRejectedUsers()
        self.connectionsStore.loadOutOfSync { _ in }
        self.connectionGroupsStore.load()
    }
}

struct ContentView_Previews: PreviewProvider {
    static let modelData = ModelData()
    static var previews: some View {
        ContentView(connectionStore: ConnectionStore(connection: modelData.connection),
                    connectionGroupStore: ConnectionGroupStore(group: modelData.groups[0], connections: modelData.connectionResponse.users))
        .environmentObject(AccountStore(user: modelData.user))
        .environmentObject(ConnectionsStore(connections: modelData.connectionResponse.users,
                                            requests: modelData.requests,
                                            blockedUsers: modelData.connectionResponse.users))
        .environmentObject(AuthorizationStore())
        .environmentObject(UsersStore(users: modelData.connectionResponse.users))
        .environmentObject(ConnectionGroupsStore(groups: modelData.groups))
        .environmentObject(ContactStore())
    }
}
