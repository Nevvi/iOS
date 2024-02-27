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
    
    var body: some View {
        NavigationView {
            List {
                Section {
//                    NavigationLink {
//
//                    } label: {
//                        HStack {
//                            Image(systemName: "exclamationmark.lock")
//                                .settingsButtonStyle()
//                            Text("Change Password")
//                        }
//                    }.padding(.vertical, 10)
                    
                    NavigationLink {
                        GroupSettings()
                    } label: {
                        HStack {
                            Image(systemName: "person.2")
                                .settingsButtonStyle()
                            Text("Permissions & Groups")
                        }
                    }.padding(.vertical, 10)
                    
                    NavigationLink {
                        BlockedUserList()
                    } label: {
                        HStack {
                            Image(systemName: "circle.slash")
                                .settingsButtonStyle()
                            Text("Blocked Users")
                        }
                    }.padding(.vertical, 10)
                    
                    NavigationLink {
                        NotificationSettings()
                    } label: {
                        HStack {
                            Image(systemName: "bell")
                                .settingsButtonStyle()
                            Text("Push Notifications")
                        }
                    }.padding(.vertical, 10)
                    
                    NavigationLink {
                        AppSettings()
                    } label: {
                        HStack {
                            Image(systemName: "gearshape.2")
                                .settingsButtonStyle()
                            Text("App Settings")
                        }
                    }.padding(.vertical, 10)
                    
                }
                
                Section {
                    NavigationLink {
                        PrivacySettings()
                    } label: {
                        HStack {
                            Image(systemName: "checkmark.shield")
                                .settingsButtonStyle()
                            Text("Privacy and security")
                        }
                    }.padding(.vertical, 10)
                    
//                    NavigationLink {
//
//                    } label: {
//                        HStack {
//                            Image(systemName: "cloud")
//                                .settingsButtonStyle()
//                            Text("Data and storage")
//                        }
//                    }.padding(.vertical, 10)
                    
                    NavigationLink {
                        FrequentlyAskedQuestionList()
                    } label: {
                        HStack {
                            Image(systemName: "questionmark.square")
                                .settingsButtonStyle()
                            Text("FAQ")
                        }
                    }.padding(.vertical, 10)
                    
//                    NavigationLink {
//
//                    } label: {
//                        HStack {
//                            Image(systemName: "headphones")
//                                .settingsButtonStyle()
//                            Text("Help Center")
//                        }
//                    }.padding(.vertical, 10)
                    
//                    NavigationLink {
//
//                    } label: {
//                        HStack {
//                            Image(systemName: "bolt")
//                                .settingsButtonStyle()
//                            Text("Feature Updates")
//                        }
//                    }.padding(.vertical, 10)
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
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
}

struct Settings_Previews: PreviewProvider {
    static let modelData = ModelData()
    static let accountStore = AccountStore(user: modelData.user)
    static let connectionGroupsStore = ConnectionGroupsStore(groups: modelData.groups)
    static let connectionGroupStore = ConnectionGroupStore(group: modelData.groups[0], connections: modelData.connectionResponse.users)
    static let connectionStore = ConnectionStore()
    
    static var previews: some View {
        Settings()
            .environmentObject(accountStore)
            .environmentObject(connectionStore)
            .environmentObject(connectionGroupStore)
            .environmentObject(connectionGroupsStore)
            .environmentObject(AuthorizationStore())
    }
}
