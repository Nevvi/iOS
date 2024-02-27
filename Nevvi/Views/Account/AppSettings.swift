//
//  Settings.swift
//  Nevvi
//
//  Created by Tyler Cobb on 1/5/23.
//

import SwiftUI


struct AppSettings: View {
    @EnvironmentObject var accountStore: AccountStore
    @EnvironmentObject var authStore: AuthorizationStore
    
    @State private var autoSync: Bool = false
    @State private var autoSyncSaving: Bool = false
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                HStack {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .settingsButtonStyle()
                    Toggle("Auto-Sync Contacts", isOn: self.$autoSync)
                        .onChange(of: self.autoSync) { newValue in
                            self.autoSyncSaving = true
                            self.accountStore.deviceSettings.autoSync = newValue
                            self.accountStore.save { _ in self.autoSyncSaving = false }
                        }
                        .disabled(self.autoSyncSaving)
                        .tint(ColorConstants.primary)
                }
                Text("Automatically sync all updated Nevvi connections with your device contacts when you log in. Otherwise you will have the option to sync manually.")
                    .settingsStyle()
                                
                Spacer()
                
                HStack(alignment: .center) {
                    Spacer()
                    Text("Version \(Bundle.main.releaseVersionNumber!) (\(Bundle.main.buildVersionNumber!))")
                        .settingsStyle()
                    Spacer()
                }
            }
            .padding(30)
        }
        .navigationTitle("App Settings")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            self.autoSync = self.accountStore.deviceSettings.autoSync
        }
    }
}

struct AppSettings_Previews: PreviewProvider {
    static let modelData = ModelData()
    static let accountStore = AccountStore(user: modelData.user)
    
    static var previews: some View {
        AppSettings()
            .environmentObject(accountStore)
            .environmentObject(AuthorizationStore())
    }
}

struct Previews_AppSettings_Previews: PreviewProvider {
    static var previews: some View {
        /*@START_MENU_TOKEN@*/Text("Hello, World!")/*@END_MENU_TOKEN@*/
    }
}
