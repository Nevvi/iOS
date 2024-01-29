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
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        messaging.token { token, error in
            if let error = error {
                print("Error fetching FCM registration token: \(error)")
            } else if let token = token {
                print("FCM registration token: \(token)")
            }
        }
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
                    .onAppear {
                        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, _ in
                            guard success else {
                                print("Notifications are disabled, not updating token")
                                return
                            }
                            
                            Messaging.messaging().token { token, error in
                                if let error = error {
                                    print("Error fetching FCM registration token: \(error)")
                                } else if let token = token {
                                    // TODO - only update on change?
                                    self.notificationStore.updateToken(token: token)
                                    print("FCM registration token: \(token)")
                                }
                            }
                            
                            UNUserNotificationCenter.current().setBadgeCount(0)
                        }
                    }
                    .onChange(of: scenePhase) { newPhase in
                        if newPhase == .active {
                            UNUserNotificationCenter.current().setBadgeCount(0)
                        }
                    }
                    .sheet(isPresented: self.$forceUpdate) {
                        self.forceUpdateView
                    }
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
                .onAppear(perform: self.checkVersion)
                .sheet(isPresented: self.$forceUpdate) {
                    self.forceUpdateView
                }
            }
        }
    }
    
    var forceUpdateView: some View {
        VStack(spacing: 20.0) {
            Text("Oh no!...")
                .onboardingTitle()
            
            Spacer()
                        
            Text("This version of Nevvi is not supported anymore. Please update to the latest version.")
                .onboardingStyle()
                .padding()

            Spacer()
            Spacer()
        }
        .padding([.leading, .trailing])
        .interactiveDismissDisabled()
    }
    
    func checkVersion() {
        self.authStore.getMinAppVersion { version in
            if Bundle.main.releaseVersionNumber! < version {
                self.forceUpdate = true
            }
            print(version)
            print(Bundle.main.releaseVersionNumber!)
            print(Bundle.main.buildVersionNumber!)
        }
    }
}
