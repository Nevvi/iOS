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
            List {
                Section {
                    NavigationLink {
                        
                    } label: {
                        HStack {
                            Image(systemName: "exclamationmark.lock").padding([.trailing])
                            Text("Change Password")
                        }
                    }.padding(10)
                    
                    NavigationLink {
                        PermissionGroupList()
                    } label: {
                        HStack {
                            Image(systemName: "person.badge.key").padding([.trailing])
                            Text("Permission Groups")
                        }
                    }.padding(10)
                    
                    NavigationLink {
                        
                    } label: {
                        HStack {
                            Image(systemName: "bell").padding([.trailing])
                            Text("Notifications")
                        }
                    }.padding(10)
                    
                    NavigationLink {
                        BlockedUserList()
                    } label: {
                        HStack {
                            Image(systemName: "circle.slash").padding([.trailing])
                            Text("Blocked Users")
                        }
                    }.padding(10)
                }
                
                Section {
                    NavigationLink {
                        
                    } label: {
                        HStack {
                            Image(systemName: "checkmark.shield").padding([.trailing])
                            Text("Privacy and security")
                        }
                    }.padding(10)
                    
                    NavigationLink {
                        
                    } label: {
                        HStack {
                            Image(systemName: "cloud").padding([.trailing])
                            Text("Data and storage")
                        }
                    }.padding(10)
                    
                    NavigationLink {
                        
                    } label: {
                        HStack {
                            Image(systemName: "questionmark.square").padding([.trailing])
                            Text("FAQ")
                        }
                    }.padding(10)
                    
                    NavigationLink {
                        
                    } label: {
                        HStack {
                            Image(systemName: "headphones").padding([.trailing])
                            Text("Help Center")
                        }
                    }.padding(10)
                    
                    NavigationLink {
                        
                    } label: {
                        HStack {
                            Image(systemName: "bolt").padding([.trailing])
                            Text("Feature Update")
                        }
                    }.padding(10)
                }
                
                Section {
                    Button(action: {
                        self.authStore.logout { res in
                            switch res {
                            case .success(_):
                                print("Logged out!")
                            case .failure(_):
                                print("Failed to log out!")
                            }
                        }
                    }, label: {
                        HStack {
                            Image(systemName: "rectangle.portrait.and.arrow.forward").padding([.trailing])
                            Text("Logout")
                            
                            Spacer ()
                            
                            Image(systemName: "chevron.right")
                                .resizable()
                                .frame(width: 8, height: 12)
                                .foregroundColor(.gray)
                        }.foregroundColor(.red)
                    })
                    .padding(10)
                    .disabled(self.authStore.loggingOut)
                    .opacity(self.authStore.loggingOut ? 0.5 : 1.0)
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
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
