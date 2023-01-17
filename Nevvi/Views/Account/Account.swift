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

    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                HStack {
                    ProfileImage(imageUrl: self.accountStore.profileImage, height: 70, width: 70)
                    
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
                
                accountOption(content: PersonalInformation(), iconName: "person", label: "Personal Information")
                accountOption(content: PermissionGroupList(), iconName: "lock", label: "Permission Groups")
                accountOption(content: BlockedUserList(), iconName: "person.2.slash", label: "Blocked Users")
                accountOption(content: Settings(), iconName: "gearshape", label: "Settings")
                
                Spacer()
                
                logoutButton
            }
            .padding(30)
            .navigationTitle("My Account")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    func accountOption(content: some View, iconName: String, label: String) -> some View {
        NavigationLink {
            content
        } label: {
            HStack {
                Image(systemName: iconName).padding([.trailing])
                Text(label)
            }.foregroundColor(.black)
        }.padding([.top], 30)
    }
    
    var logoutButton: some View {
        Button(action: self.logout, label: {
            HStack {
                Image(systemName: "rectangle.portrait.and.arrow.forward").padding([.trailing])
                Text("Logout")
            }
            .foregroundColor(self.authStore.loggingOut ? .gray : .black)
        })
        .disabled(self.authStore.loggingOut)
        .padding([.bottom], 30)
    }
    
    func logout() {
        self.authStore.logout { (result: Result<Bool, Error>) in
            switch result {
            case .failure(let error):
                print("Something went wrong", error)
            case .success(_):
                self.accountStore.reset()
            }
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
