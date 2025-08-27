//
//  NevviApp.swift
//  Nevvi
//
//  Created by Tyler Cobb on 12/29/22.
//

import SwiftUI
import BackgroundTasks

import Firebase
import FirebaseMessaging
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate, MessagingDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
        application.registerForRemoteNotifications()
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().setAPNSToken(deviceToken, type: .unknown)
    }
}

@main
struct NevviApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @Environment(\.scenePhase) var scenePhase
    
    @StateObject private var modelData = ModelData()
    
    @StateObject private var authStore = AuthorizationStore()
    @StateObject private var accountStore = AccountStore()
    @StateObject private var connectionStore = ConnectionStore()
    @StateObject private var connectionSuggestionStore = ConnectionSuggestionStore()
    @StateObject private var connectionsStore = ConnectionsStore()
    @StateObject private var connectionGroupStore = ConnectionGroupStore()
    @StateObject private var connectionGroupsStore = ConnectionGroupsStore()
    @StateObject private var usersStore = UsersStore()
    @StateObject private var contactStore = ContactStore()
    @StateObject private var notificationStore = NotificationStore()
    @StateObject private var messagingStore = MessagingStore()
    
    @State private var forceUpdate = false
    

    var body: some Scene {
        WindowGroup {
            if (self.authStore.authorization != nil) {
                ContentView()
                    .environment(\.sizeCategory, .medium)
                    .environmentObject(accountStore)
                    .environmentObject(authStore)
                    .environmentObject(connectionStore)
                    .environmentObject(connectionSuggestionStore)
                    .environmentObject(connectionsStore)
                    .environmentObject(connectionGroupStore)
                    .environmentObject(connectionGroupsStore)
                    .environmentObject(usersStore)
                    .environmentObject(contactStore)
                    .environmentObject(notificationStore)
                    .environmentObject(messagingStore)
                    .onAppear(perform: self.checkVersion)
                    .onChange(of: scenePhase) { newPhase in
                        if newPhase == .active {
                            self.authStore.checkAuthorization()
                            UNUserNotificationCenter.current().setBadgeCount(0)
                        }
                    }
                    .sheet(isPresented: self.$forceUpdate) {
                        self.forceUpdateView
                    }
                    .navigationViewStyle(.stack)
            } else {
                Login(authStore: authStore) { (auth: Authorization) in
                    // hacky way of restoring auth on login
                    self.accountStore.authorization = auth
                    self.connectionStore.authorization = auth
                    self.connectionsStore.authorization = auth
                    self.connectionSuggestionStore.authorization = auth
                    self.connectionGroupStore.authorization = auth
                    self.connectionGroupsStore.authorization = auth
                    self.usersStore.authorization = auth
                    self.contactStore.authorization = auth
                    self.notificationStore.authorization = auth
                }
                .environment(\.sizeCategory, .medium)
                .onAppear(perform: self.checkVersion)
                .sheet(isPresented: self.$forceUpdate) {
                    self.forceUpdateView
                }
                .navigationViewStyle(.stack)
            }
        }
    }
    
    var forceUpdateView: some View {
        ZStack {
            Image("BackgroundBlur")
                .resizable()
                .aspectRatio(contentMode: .fill)
            
            VStack(spacing: 20) {
                Image(systemName: "arrow.down.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                
                Text("Update Required")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("A new version of Nevvi is available. Please update to continue using the latest features.")
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Button("Update Now") {
                    openAppStore()
                }
                .buttonStyle(.bordered)
            }
            .padding()
            .interactiveDismissDisabled()
        }
    }
        
    private func openAppStore() {
        guard let url = URL(string: "https://apps.apple.com/us/app/nevvi/id1669915435") else { return }
        
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
    
    func checkVersion() {
        self.authStore.getMinAppVersion { version in
            let bundleVersion = Bundle.main.releaseVersionNumber!
            if Bundle.main.releaseVersionNumber!.isVersionLessThan(version) {
                print("Forcing update to min version \(version)")
                print("Current version \(Bundle.main.releaseVersionNumber!) \(Bundle.main.buildVersionNumber!)")
                self.forceUpdate = true
            }
        }
    }
}
