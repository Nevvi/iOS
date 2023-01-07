//
//  Settings.swift
//  Nevvi
//
//  Created by Tyler Cobb on 1/5/23.
//

import SwiftUI

struct Settings: View {
    @EnvironmentObject var accountStore: AccountStore
    @EnvironmentObject var authStore: AuthorizationStore
    
    @State private var syncContacts: Bool = false
    @State private var showError: Bool = false
    @State private var error: Error? = nil
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                HStack {
                    Image(systemName: "rectangle.portrait.and.arrow.forward").padding([.trailing], 5)
                    Toggle("Auto-sync Contacts", isOn: self.$syncContacts)
                }
                Text("Automatically sync all Nevvi connections with your device contacts when you log in")
                    .multilineTextAlignment(.leading)
                    .foregroundColor(.secondary)
                    .fontWeight(.light)
                    .font(.system(size: 16))
                
                Divider()
                    .padding()
                
                HStack {
                    Image(systemName: "rectangle.portrait.and.arrow.forward").padding([.trailing], 5)
                    Toggle("Update all information", isOn: self.$syncContacts)
                }
                Text("Update all contact information including name and birthday when a connection changes instead of just email, phone, and address")
                    .multilineTextAlignment(.leading)
                    .foregroundColor(.secondary)
                    .fontWeight(.light)
                    .font(.system(size: 16))
                
                Divider()
                    .padding()
                
                HStack {
                    Image(systemName: self.authStore.biometricType() == .face ? "faceid" : "touchid").padding([.trailing], 5)
                    Toggle("Enabled \(self.authStore.biometricType() == .face ? "Face" : "Touch") ID", isOn: self.$syncContacts)
                }
                Text("Have option to use biometric login instead of inputting your username and password every time")
                    .multilineTextAlignment(.leading)
                    .foregroundColor(.secondary)
                    .fontWeight(.light)
                    .font(.system(size: 16))
                
                Spacer()
            }
            .padding(30)
            .alert(isPresented: self.$showError) {
                Alert(title: Text("Something went wrong"), message: Text(self.error!.localizedDescription))
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
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
