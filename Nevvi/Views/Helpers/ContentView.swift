//
//  ContentView.swift
//  Nevvi
//
//  Created by Tyler Cobb on 12/29/22.
//

import SwiftUI
import AlertToast

struct ContentView: View {
    @Environment(\.scenePhase) var scenePhase
    
    @EnvironmentObject var authorizationStore: AuthorizationStore
    @EnvironmentObject var accountStore: AccountStore
    @EnvironmentObject var authStore: AuthorizationStore
    @EnvironmentObject var connectionStore: ConnectionStore
    @EnvironmentObject var connectionsStore: ConnectionsStore
    @EnvironmentObject var connectionGroupsStore: ConnectionGroupsStore
    @EnvironmentObject var connectionGroupStore: ConnectionGroupStore
    @EnvironmentObject var suggestionsStore: ConnectionSuggestionStore
    @EnvironmentObject var usersStore: UsersStore
    @EnvironmentObject var contactStore: ContactStore

    var body: some View {
        VStack {
            if (!accountStore.id.isEmpty) {
                if (accountStore.onboardingCompleted) {
                    TabView {
                        ConnectionList()
                            .tabItem() {
                                Label("Connections", systemImage: "person.3.sequence.fill")
                            }
                            .badge(connectionsStore.requestCount)
                        
                        ConnectionGroupList()
                            .tabItem() {
                                Label("Groups", systemImage: "person.2")
                            }

                        PersonalInformation()
                            .tabItem() {
                                Label("Profile", systemImage: "person.circle.fill")
                            }
                        
                        Settings()
                            .tabItem() {
                                Label("More", systemImage: "line.3.horizontal")
                            }
                    }
                    .onChange(of: scenePhase) { newPhase in
                        if newPhase == .active {
                            /// App became active - individual stores can handle refreshing if needed
                            /// The authorization check in NevviApp will handle token refresh
                        }
                    }
                    .onOpenURL { incomingURL in
                        /// Responds to any URLs opened with our app. In this case, the URLs defined inside the URL Types section.
                        print("App was opened via URL: \(incomingURL)")
                        handleIncomingURL(incomingURL)
                    }
                } else {
                    OnboardingCarousel()
                }
            } else {
                // Show loading when account data isn't available yet
                LoadingView(loadingText: "Fetching your profile...")
            }
        }
        .errorAlert(error: self.$accountStore.error)
        .errorAlert(error: self.$connectionStore.error)
        .errorAlert(error: self.$connectionsStore.error)
        .errorAlert(error: self.$connectionGroupStore.error)
        .errorAlert(error: self.$connectionGroupsStore.error)
        .errorAlert(error: self.$usersStore.error)
        .errorAlert(error: self.$suggestionsStore.error)
        .errorAlert(error: self.$contactStore.error)
    }
    
    func reload() {
        if (self.authorizationStore.authorization == nil) {
            return
        }
        
        self.accountStore.load()
        self.connectionsStore.load()
        self.connectionsStore.loadRequests()
        self.connectionsStore.loadRejectedUsers()
        self.connectionsStore.loadOutOfSync { _ in }
        self.connectionGroupsStore.load()
        self.suggestionsStore.loadSuggestions()
    }
    
    /// Handles the incoming URL and performs validations before acknowledging.
    private func handleIncomingURL(_ url: URL) {
        guard url.scheme == "nevvi" else {
            return
        }
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            print("Invalid URL")
            return
        }

        guard let action = components.host, action == "request-connection" else {
            print("Unknown URL, we can't handle this one!")
            return
        }
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
        .environmentObject(ConnectionSuggestionStore(users: []))
        .environmentObject(NotificationStore())
        .environmentObject(ContactStore())
        .environmentObject(ConnectionSuggestionStore(users: modelData.connectionResponse.users))
        .environmentObject(ConnectionStore(connection: modelData.connection))
        .environmentObject(ConnectionGroupStore(group: modelData.groups[0], connections: modelData.connectionResponse.users))
    }
}
