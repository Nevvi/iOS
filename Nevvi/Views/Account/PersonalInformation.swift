//
//  AccountView.swift
//  Nevvi
//
//  Created by Tyler Cobb on 12/29/22.
//

import SwiftUI
import WrappingHStack

struct PersonalInformation: View {
    @EnvironmentObject var accountStore: AccountStore
    @EnvironmentObject var authStore: AuthorizationStore
    
    private var isBirthdayEmpty: Bool {
        return self.accountStore.birthday.yyyyMMdd() == Date().yyyyMMdd()
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 12) {
                    HStack(alignment: .center) {
                        Spacer()
                        VStack(alignment: .center, spacing: 4) {
                            ProfileImage(imageUrl: self.accountStore.profileImage, height: 108, width: 108)
                            
                            Text("\(self.accountStore.firstName) \(self.accountStore.lastName)")
                                .defaultStyle(size: 22, opacity: 1.0)
                            
                            Text(self.accountStore.bio)
                                .defaultStyle(size: 16, opacity: 0.6)
                        }
                        Spacer()
                    }.padding(.bottom)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Phone Number").personalInfoLabel()
                        
                        HStack(alignment: .center, spacing: 8) {
                            Text(self.accountStore.phoneNumber)
                                .defaultStyle(size: 16, opacity: 1.0)
                            
                            Spacer()
                            
                            Text("Home").asDefaultBadge()
                        }
                        .padding(.horizontal, 0)
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Divider().padding([.bottom], 4)
                        
                        fieldPermissionGroups(field: "phoneNumber")
                    }.informationSection()
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Email").personalInfoLabel()
                        
                        HStack(alignment: .center, spacing: 8) {
                            Text(self.accountStore.email)
                                .defaultStyle(size: 16, opacity: 1.0)
                            
                            Spacer()
                            
                            Text("Personal").asDefaultBadge()
                        }
                        .padding(.horizontal, 0)
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Divider().padding([.bottom], 4)
                        
                        fieldPermissionGroups(field: "email")
                    }.informationSection()
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Address").personalInfoLabel()
                        
                        HStack(alignment: .top, spacing: 8) {
                            Text(self.accountStore.address.isEmpty ? "" : self.accountStore.address.toString())
                                .defaultStyle(size: 16, opacity: 1.0)
                            
                            Spacer()
                            
                            Text("Home").asDefaultBadge()
                        }
                        .padding([.vertical], 8)
                        .padding([.horizontal], 0)
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                        
                        Divider().padding([.bottom], 4)
                        
                        fieldPermissionGroups(field: "address")
                    }.informationSection()
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Birthday").personalInfoLabel()
                        
                        Text(self.isBirthdayEmpty ? "" : self.accountStore.birthday.toString())
                            .defaultStyle(size: 16, opacity: 1.0)
                            .padding([.vertical], 8)
                        
                        Divider().padding([.bottom], 4)
                        
                        fieldPermissionGroups(field: "birthday")
                    }.informationSection()
                    
                    Spacer()
                    
                    NavigationLink(destination: PersonalInformationEdit()) {
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
                    }
                }
                .padding()
                .background(ColorConstants.background)
            }
            .background(ColorConstants.background)
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
//            .toolbar(content: {
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    // TODO
//                    Image(systemName: "qrcode")
//                        .toolbarButtonStyle()
//                }
//            })
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
