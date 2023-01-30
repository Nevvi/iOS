//
//  Settings.swift
//  Nevvi
//
//  Created by Tyler Cobb on 1/5/23.
//

import SwiftUI

extension Text {
    func settingsStyle() -> some View {
        return self
            .multilineTextAlignment(.leading)
            .foregroundColor(.secondary)
            .fontWeight(.light)
            .font(.system(size: 16))
    }
}

struct Settings: View {
    @EnvironmentObject var accountStore: AccountStore
    @EnvironmentObject var authStore: AuthorizationStore
    
    @State private var autoSync: Bool = false
    @State private var autoSyncSaving: Bool = false
    
    @State private var syncAllInformation: Bool = false
    @State private var syncAllInformationSaving: Bool = false
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                HStack {
                    Image(systemName: "rectangle.portrait.and.arrow.forward").padding([.trailing], 5)
                    Toggle("Auto-sync Contacts", isOn: self.$autoSync)
                        .onChange(of: self.autoSync) { newValue in
                            self.autoSyncSaving = true
                            self.accountStore.deviceSettings.autoSync = newValue
                            self.accountStore.save { _ in self.autoSyncSaving = false }
                        }
                        .disabled(self.autoSyncSaving)
                        .tint(ColorConstants.secondary)
                }
                Text("Automatically sync all updated Nevvi connections with your device contacts when you log in. Otherwise you will have the option to sync manually.")
                    .settingsStyle()
                
                Divider().padding()
                
                HStack {
                    Image(systemName: "rectangle.portrait.and.arrow.forward").padding([.trailing], 5)
                    Toggle("Update all information", isOn: self.$syncAllInformation)
                        .onChange(of: self.syncAllInformation) { newValue in
                            self.syncAllInformationSaving = true
                            self.accountStore.deviceSettings.syncAllInformation = newValue
                            self.accountStore.save { _ in self.syncAllInformationSaving = false }
                        }
                        .disabled(self.syncAllInformationSaving)
                        .tint(ColorConstants.secondary)
                }
                Text("Update all contact information available including name and birthday when a connection changes instead of just email, phone, and address")
                    .settingsStyle()
                
                Spacer()
            }
            .padding(30)
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            self.autoSync = self.accountStore.deviceSettings.autoSync
            self.syncAllInformation = self.accountStore.deviceSettings.syncAllInformation
        }
    }
}

struct Settings_Previews: PreviewProvider {
    static let modelData = ModelData()
    static let accountStore = AccountStore(user: modelData.user)
    
    static var previews: some View {
        Settings()
            .environmentObject(accountStore)
            .environmentObject(AuthorizationStore())
    }
}
