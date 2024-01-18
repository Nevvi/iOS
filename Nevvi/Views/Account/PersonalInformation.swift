//
//  AccountView.swift
//  Nevvi
//
//  Created by Tyler Cobb on 12/29/22.
//

import SwiftUI
import WrappingHStack

extension VStack {
    func personalInfoStyle() -> some View {
        return self
            .padding([.leading, .trailing])
            .padding([.bottom], 12)
    }
}

struct PersonalInformation: View {
    @EnvironmentObject var accountStore: AccountStore
    @EnvironmentObject var authStore: AuthorizationStore
    
    private var isBirthdayEmpty: Bool {
        return self.accountStore.birthday.yyyyMMdd() == Date().yyyyMMdd()
    }
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    HStack(alignment: .center) {
                        Spacer()
                        VStack {
                            ProfileImage(imageUrl: self.accountStore.profileImage, height: 100, width: 100)
                            
                            Text("\(self.accountStore.firstName) \(self.accountStore.lastName)")
                                .font(.system(size: 22, weight: .medium))
                            
                            Text(self.accountStore.bio)
                        }
                        Spacer()
                    }
                }
                .listRowBackground(Color.clear)

                Section {
                    VStack(alignment: .leading) {
                        Text("Phone Number").personalInfoLabel()

                        Text(self.accountStore.phoneNumber)
                            .personalInfoStyle()
                        
                        Divider()
                        
                        fieldPermissionGroups(field: "phoneNumber")
                    }
                }

                Section {
                    VStack(alignment: .leading) {
                        Text("Email").personalInfoLabel()

                        Text(self.accountStore.email)
                            .personalInfoStyle()
                        
                        Divider()
                        
                        fieldPermissionGroups(field: "email")
                    }
                }

                Section {
                    VStack(alignment: .leading) {
                        Text("Address").personalInfoLabel()
                        
                        HStack(alignment: self.accountStore.address.isEmpty ? .center : .top) {
                            Text(self.accountStore.address.isEmpty ? "" : self.accountStore.address.toString())
                            
                            Spacer()
                            
                            Text("Home")
                                .font(.system(size: 12))
                                .padding([.leading, .trailing], 10)
                                .padding([.top, .bottom], 6)
                                .foregroundColor(Color.white)
                                .background(ColorConstants.primary)
                                .cornerRadius(30)
                                .fontWeight(.semibold)
                        }
                        .padding([.vertical], 6)
                        
                        Divider()

                        fieldPermissionGroups(field: "address")
                    }
                }

                Section {
                    VStack(alignment: .leading) {
                        Text("Birthday")
                            .personalInfoLabel()

                        Text(self.isBirthdayEmpty ? "" : self.accountStore.birthday.toString())
                            .personalInfoStyle()

                        Divider()

                        fieldPermissionGroups(field: "birthday")
                    }
                    .padding([.top, .bottom], 5)
                }
                
                Section {
                    ZStack {
                        Text("Edit Profile".uppercased())
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 24)
                                    .foregroundColor(ColorConstants.primary)
                            )
                        
                        NavigationLink(destination: PersonalInformationEdit()) {
                            EmptyView()
                        }
                    }
                }.listRowBackground(Color.clear)
            }
            .padding([.top], -25)
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    func fieldPermissionGroups(field: String) -> some View {
        FieldPermissionGroupPicker(canEdit: false, fieldName: field, permissionGroups: self.accountStore.permissionGroups.map { $0.copy() })
    }

}

struct PersonalInformation_Previews: PreviewProvider {
    static let modelData = ModelData()
    static let authStore = AuthorizationStore()
    static let accountStore = AccountStore(user: modelData.user)

    static var previews: some View {
        PersonalInformation()
            .environmentObject(accountStore)
            .environmentObject(authStore)
    }
}
