//
//  NevviApp.swift
//  Nevvi
//
//  Created by Tyler Cobb on 12/29/22.
//

import SwiftUI
import BackgroundTasks

@main
struct NevviApp: App {
//    @Environment(\.scenePhase) private var phase
    
    @StateObject private var modelData = ModelData()
    
    @StateObject private var authStore = AuthorizationStore()
    @StateObject private var accountStore = AccountStore()
    @StateObject private var connectionStore = ConnectionStore()
    @StateObject private var connectionsStore = ConnectionsStore()
    @StateObject private var connectionGroupStore = ConnectionGroupStore()
    @StateObject private var connectionGroupsStore = ConnectionGroupsStore()
    @StateObject private var usersStore = UsersStore()
    @StateObject private var contactStore = ContactStore()
    
//    func scheduleLoadOutOfSync() {
//        print("Scheduling background sync task")
//        let request = BGAppRefreshTaskRequest(identifier: "loadoutofsync")
//        request.earliestBeginDate = Calendar.current.date(byAdding: .second, value: 30, to: Date()) // Mark 2
//        try? BGTaskScheduler.shared.submit(request)
//        print("Submitted request")
//    }
    
    var body: some Scene {
        WindowGroup {
            if (self.authStore.authorization != nil) {
                ContentView(connectionStore: self.connectionStore, connectionGroupStore: self.connectionGroupStore)
                    .environmentObject(accountStore)
                    .environmentObject(authStore)
                    .environmentObject(connectionsStore)
                    .environmentObject(connectionGroupsStore)
                    .environmentObject(usersStore)
                    .environmentObject(contactStore)
            } else {
                Login(authStore: authStore) { (auth: Authorization) in
                    // hacky way of restoring auth on login
                    self.accountStore.authorization = auth
                    self.connectionStore.authorization = auth
                    self.connectionsStore.authorization = auth
                    self.connectionGroupStore.authorization = auth
                    self.connectionGroupsStore.authorization = auth
                    self.usersStore.authorization = auth
                    self.contactStore.authorization = auth
                    
                    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                        if success {
                            self.connectionsStore.loadOutOfSync { (result: Result<ConnectionResponse, Error>) in
                                switch result {
                                case .success(let response):
                                    print("Got \(response.count) out of sync connection(s)")
                                    UIApplication.shared.applicationIconBadgeNumber = response.count
                                case .failure(let error):
                                    print("Failed to load out of sync connections", error.localizedDescription)
                                }
                            }
                        } else if let error = error {
                            print(error.localizedDescription)
                        }
                    }
                }
            }
        }
//        .onChange(of: phase) { newPhase in
//            switch newPhase {
//            case .background: scheduleLoadOutOfSync()
//            default: break
//            }
//        }
//        .backgroundTask(.appRefresh("loadoutofsync")) {
//            print("Loading out of sync connections")
//            let auth = await self.authStore.authorization
//            if (auth == nil) {
//                return
//            }
//
//            let userId: String? = auth?.id
//            var urlString = "\(BuildConfiguration.shared.baseURL)/user/v1/users/\(userId!)/connections?inSync=false"
//            var request = URLRequest(url: URL(string: urlString)!)
//            request.httpMethod = "GET"
//            request.setValue(auth?.idToken, forHTTPHeaderField: "Authorization")
//
//            guard let data = try? await URLSession.shared.data(for: request).0 else {
//                return
//            }
//
//            let decoder = JSONDecoder()
//            guard let response = try? decoder.decode(ConnectionResponse.self, from: data) else {
//                return
//            }
//
//            print("Got \(response.count) out of sync connection(s)")
//            await MainActor.run(body: {
//                UIApplication.shared.applicationIconBadgeNumber = response.count
//            })
//        }
    }
}
