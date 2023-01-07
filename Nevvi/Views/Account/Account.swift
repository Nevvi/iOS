//
//  AccountView.swift
//  Nevvi
//
//  Created by Tyler Cobb on 12/29/22.
//

import SwiftUI

struct Account: View {
    @EnvironmentObject var accountStore: AccountStore
    @EnvironmentObject var authStore: AuthorizationStore
    
    @State private var showError: Bool = false
    @State private var error: Error? = nil

    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                HStack {
                    AsyncImage(url: URL(string: self.accountStore.profileImage), content: { image in
                        image.resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(maxWidth: 70, maxHeight: 70)
                            .clipShape(Circle())
                    }, placeholder: {
                        Image(systemName: "photo.circle")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 70, height: 70)
                            .foregroundColor(.gray)
                            .clipShape(Circle())
                    })
                    
                    VStack(alignment: .leading) {
                        Text("\(self.accountStore.firstName) \(self.accountStore.lastName)")
                            .foregroundColor(.primary)
                            .font(.system(size: 18))
                            .padding([.bottom], 0.5)
                        
                        Text(self.accountStore.email)
                            .foregroundColor(.secondary)
                            .font(.system(size: 14))
                    }
                    .padding([.leading], 3)
                }.padding([.bottom], 10)
                
                Divider()
                
                NavigationLink {
                    PersonalInformation()
                } label: {
                    HStack {
                        Image(systemName: "person").padding([.trailing])
                        Text("Personal Information")
                    }.foregroundColor(.black)
                }.padding([.top], 50)
                
                NavigationLink {
                    Settings()
                } label: {
                    HStack {
                        Image(systemName: "gearshape").padding([.trailing])
                        Text("Settings")
                    }.foregroundColor(.black)
                }.padding([.top], 30)
                
                NavigationLink {
                    Text("Notifications")
                } label: {
                    HStack {
                        Image(systemName: "bell").padding([.trailing])
                        Text("Notifications")
                    }.foregroundColor(.black)
                }.padding([.top], 30)
                
                NavigationLink {
                    BlockedUserList()
                } label: {
                    HStack {
                        Image(systemName: "person.2.slash").padding([.trailing])
                        Text("Blocked Users")
                    }.foregroundColor(.black)
                }.padding([.top], 30)
                
                Spacer()
                
                Button(action: {
                    self.authStore.logout { (result: Result<Bool, Error>) in
                        switch result {
                        case .failure(let error):
                            self.error = error
                            self.showError = true
                        case .success(_):
                            self.accountStore.reset()
                        }
                    }
                }, label: {
                    HStack {
                        Image(systemName: "rectangle.portrait.and.arrow.forward").padding([.trailing])
                        Text("Logout")
                    }
                    .foregroundColor(self.authStore.loggingOut ? .gray : .black)
                })
                .disabled(self.authStore.loggingOut)
                .padding([.bottom], 30)
            }
            .padding(30)
            .alert(isPresented: self.$showError) {
                Alert(title: Text("Something went wrong"), message: Text(self.error!.localizedDescription))
            }
            .navigationTitle("My Account")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

}

struct AccountView_Previews: PreviewProvider {
    static let modelData = ModelData()
    static let authStore = AuthorizationStore()
    static let usersStore = UsersStore(users: modelData.connectionResponse.users)
    static let accountStore = AccountStore(user: modelData.user)
    static let connectionsStore = ConnectionsStore(connections: modelData.connectionResponse.users,
                                                   requests: modelData.requests,
                                                   blockedUsers: modelData.connectionResponse.users)

    static var previews: some View {
        Account()
           .environmentObject(accountStore)
           .environmentObject(authStore)
           .environmentObject(usersStore)
           .environmentObject(connectionsStore)
    }
}
