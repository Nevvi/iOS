//
//  Settings.swift
//  Nevvi
//
//  Created by Tyler Cobb on 1/5/23.
//

import AlertToast
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
    
    @State private var toastText: String = ""
    @State private var showToast: Bool = false
    @State private var showDeleteAlert: Bool = false
    
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
                        PermissionGroupList()
                    } label: {
                        HStack {
                            Image(systemName: "lock")
                                .settingsButtonStyle()
                            Text("Permission Groups")
                        }
                    }.padding(.vertical, 10)
                    
                    NavigationLink {
                        InviteUsers()
                    } label: {
                        HStack {
                            Image(systemName: "person.badge.plus")
                                .settingsButtonStyle()
                            Text("Invite users")
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
                                self.accountStore.reset()
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
                
                Section {
                    Button(action: {
                        self.showDeleteAlert = true
                    }, label: {
                        HStack {
                            Image(systemName: "minus.circle").padding([.trailing])
                            Text("Delete Account")
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
            .alert(isPresented: self.$showDeleteAlert) {
                deleteAlert
            }
            .toast(isPresenting: $showToast, duration: 3){
                AlertToast(displayMode: .alert, type: .complete(Color.green), title: self.toastText)
            }
        }
    }
    
    var deleteAlert: Alert {
        Alert(title: Text("Delete confirmation"), message: Text("Are you sure you want to delete your account and all of your connections?"), primaryButton: .destructive(Text("Delete")) {
            self.accountStore.delete { (result: Result<String, Error>) in
                switch result {
                case.success(let message):
                    self.toastText = message
                case .failure(let error):
                    self.toastText = error.localizedDescription
                }
                self.showToast = true
            }
            
            self.showDeleteAlert = false
        }, secondaryButton: .cancel() {
            self.showDeleteAlert = false
        })
    }
    
}

struct Settings_Previews: PreviewProvider {
    static let modelData = ModelData()
    static let accountStore = AccountStore(user: modelData.user)
    static let connectionGroupsStore = ConnectionGroupsStore(groups: modelData.groups)
    static let connectionGroupStore = ConnectionGroupStore(group: modelData.groups[0], connections: modelData.connectionResponse.users)
    static let connectionStore = ConnectionStore()
    static let contactStore = ContactStore(contactsOnNevvi: [], contactsNotOnNevvi: [
        ContactStore.ContactInfo(firstName: "John", lastName: "Doe", phoneNumber: "6129631237"),
        ContactStore.ContactInfo(firstName: "Jane", lastName: "Doe", phoneNumber: "6129631238"),
    ])
    static let connectionsStore = ConnectionsStore(connections: modelData.connectionResponse.users,
                                                   requests: modelData.requests,
                                                   blockedUsers: [])
    
    static var previews: some View {
        Settings()
            .environmentObject(accountStore)
            .environmentObject(connectionStore)
            .environmentObject(connectionGroupStore)
            .environmentObject(connectionGroupsStore)
            .environmentObject(AuthorizationStore())
            .environmentObject(NotificationStore())
            .environmentObject(contactStore)
            .environmentObject(connectionsStore)
    }
}
