//
//  NotificationSettings.swift
//  Nevvi
//
//  Created by Tyler Standal on 1/29/24.
//

import SwiftUI
import AlertToast

struct NotificationSettings: View {
    @EnvironmentObject var accountStore: AccountStore
    @EnvironmentObject var notificationStore: NotificationStore
    
    @State private var notifyOutOfSyncSaving: Bool = false
    private var notifyOutOfSync: Binding<Bool> { Binding (
        get: {
            self.notificationStore.hasAccess && self.accountStore.deviceSettings.notifyOutOfSync
        },
        set: {
            self.notifyOutOfSyncSaving = true
            self.accountStore.deviceSettings.notifyOutOfSync = $0
            self.accountStore.save { _ in self.notifyOutOfSyncSaving = false }
        }
    )}
    
    @State private var notifyBirthdaysSaving: Bool = false
    private var notifyBirthdays: Binding<Bool> { Binding (
        get: {
            self.notificationStore.hasAccess && self.accountStore.deviceSettings.notifyBirthdays
        },
        set: {
            self.notifyBirthdaysSaving = true
            self.accountStore.deviceSettings.notifyBirthdays = $0
            self.accountStore.save { _ in self.notifyBirthdaysSaving = false }
        }
    )}
    
    @State private var helperText: String = ""
    @State private var showHelper: Bool = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack {
                    HStack {
                        Image(systemName: "bell")
                            .settingsButtonStyle()
                        Text("Push Notifications")
                        
                        Spacer()
                        
                        Text(self.notificationStore.hasAccess ? "Enabled" : "Disabled")
                            .bold()
                    }
                    Text("You can enable or disable notifications inside your device settings.")
                        .settingsStyle()
                }
                
                Divider()
                
                VStack {
                    HStack {
                        Image(systemName: "exclamationmark.arrow.triangle.2.circlepath")
                            .settingsButtonStyle()
                        Toggle("Sync Notifications", isOn: self.notifyOutOfSync)
                            .disabled(self.notifyOutOfSyncSaving || !self.notificationStore.hasAccess)
                            .tint(ColorConstants.primary)
                            .onTapGesture {
                                if !self.notificationStore.hasAccess {
                                    self.helperText = "Push notifications must be enabled"
                                    self.showHelper = true
                                }
                            }
                    }
                    Text("We'll send you a notification daily if any of your connections have changed since you last synced.")
                        .settingsStyle()
                }
                
                VStack {
                    HStack {
                        Image(systemName: "birthday.cake")
                            .settingsButtonStyle()
                        Toggle("Birthday Notifications", isOn: self.notifyBirthdays)
                            .disabled(self.notifyBirthdaysSaving || !self.notificationStore.hasAccess)
                            .tint(ColorConstants.primary)
                            .onTapGesture {
                                if !self.notificationStore.hasAccess {
                                    self.helperText = "Push notifications must be enabled"
                                    self.showHelper = true
                                }
                            }
                    }
                    Text("We'll send you a notification on the day of your connection's birthday.")
                        .settingsStyle()
                }
                
                Spacer()
            }
            .padding(30)
            .multilineTextAlignment(.center)
            .navigationTitle("Notifications")
            .navigationBarTitleDisplayMode(.inline)
            .toast(isPresenting: $showHelper, duration: 4){
                AlertToast(displayMode: .banner(.pop), type: .systemImage("exclamationmark.triangle", Color.gray), title: self.helperText)
            }
            .onAppear {
                self.reload()
            }
        }
        .refreshable {
            self.reload()
        }
    }
    
    private func reload() {
        self.notificationStore.checkRequestAccess()
    }
}

struct NotificationSettings_Previews: PreviewProvider {
    static let modelData = ModelData()
    static let accountStore = AccountStore(user: modelData.user)
    
    static var previews: some View {
        NotificationSettings()
            .environmentObject(NotificationStore())
            .environmentObject(accountStore)
    }
}
