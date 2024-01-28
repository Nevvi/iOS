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
    @EnvironmentObject var connectionStore: ConnectionStore
    @EnvironmentObject var connectionGroupStore: ConnectionGroupStore
    
    var body: some View {
        if (!accountStore.id.isEmpty) {
            if (accountStore.onboardingCompleted) {
                TabView {
                    ConnectionList()
                        .tabItem() {
                            Label("Connections", systemImage: "person.3.sequence.fill")
                        }
                    
                    ConnectionRequestList()
                        .tabItem() {
                            Label("Requests", systemImage: "plus.circle.fill")
                        }
                    
                    NotificationList()
                        .tabItem() {
                            Label("Notification", systemImage: "bell")
                        }
                    
                    PersonalInformation()
                        .tabItem() {
                            Label("Profile", systemImage: "person.circle.fill")
                        }
                    
                    Settings()
                        .tabItem() {
                            Label("Settings", systemImage: "gearshape.fill")
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
        ContentView()
        .environmentObject(AccountStore(user: modelData.user))
        .environmentObject(ConnectionsStore(connections: modelData.connectionResponse.users,
                                            requests: modelData.requests,
                                            blockedUsers: modelData.connectionResponse.users))
        .environmentObject(AuthorizationStore())
        .environmentObject(UsersStore(users: modelData.connectionResponse.users))
        .environmentObject(ConnectionGroupsStore(groups: modelData.groups))
        .environmentObject(ContactStore())
        .environmentObject(ConnectionSuggestionStore(users: modelData.connectionResponse.users))
        .environmentObject(ConnectionStore(connection: modelData.connection))
        .environmentObject(ConnectionGroupStore(group: modelData.groups[0], connections: modelData.connectionResponse.users))
    }
}
