//
//  AccountView.swift
//  Nevvi
//
//  Created by Tyler Cobb on 12/29/22.
//

import SwiftUI
import WrappingHStack
import CoreImage.CIFilterBuiltins

struct PersonalInformation: View {
    @EnvironmentObject var accountStore: AccountStore
    @EnvironmentObject var authStore: AuthorizationStore
    
    let context = CIContext()
    let filter = CIFilter.qrCodeGenerator()
    
    @State var showQrCode: Bool = false
    
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
                    }.padding(.vertical)
                    
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
                            .asPrimaryButton()
                    }
                }
                .padding(.bottom)
                .background(ColorConstants.background)
            }
            .padding([.horizontal, .bottom])
            .background(ColorConstants.background)
            .toolbar {
//                ToolbarItem(placement: .navigationBarLeading) {
//                    Image(systemName: "qrcode")
//                        .toolbarButtonStyle()
//                        .onTapGesture {
//                            self.showQrCode = true
//                        }
//                        .padding(.trailing, -8)
//                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: PersonalInformationEdit()) {
                        Image(systemName: "square.and.pencil")
                            .toolbarButtonStyle()
                    }
                }
            }
            .sheet(isPresented: self.$showQrCode) {
                qrCodeSheet
                    .presentationDetents([.fraction(0.66)])
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    func fieldPermissionGroups(field: String) -> some View {
        FieldPermissionGroupPicker(canEdit: false, fieldName: field, permissionGroups: self.accountStore.permissionGroups.map { $0.copy() })
    }
    
    var qrCodeSheet: some View {
        VStack(alignment: .center, spacing: 12) {
            Text("Share the QR code and connect easily")
                .defaultStyle(size: 18, opacity: 0.6)
                .multilineTextAlignment(.center)

            Spacer()
            
            ZStack {
                Image(uiImage: generateQRCode())
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                
                Image("AppLogo")
                    .frame(width: 68, height: 68)
                    .overlay(
                      RoundedRectangle(cornerRadius: 48)
                        .inset(by: 2)
                        .stroke(.black, lineWidth: 4)
                    )
            }
            .padding(24)
            .cornerRadius(48)
            .overlay(
              RoundedRectangle(cornerRadius: 48)
                .inset(by: 2)
                .stroke(ColorConstants.primary, lineWidth: 4)
            )
            
            Spacer ()
            
            HStack(alignment: .top, spacing: 8) {
                Text("Share")
                    .asDefaultButton()
                
                Text("Close")
                    .asDefaultButton()
                    .onTapGesture {
                        self.showQrCode = false
                    }
            }
            .padding(0)
            .frame(maxWidth: .infinity, alignment: .topLeading)
        }
        .padding(.horizontal, 24)
        .padding(.top, 32)
        .padding(.bottom, 24)
        .background(.white)
        .cornerRadius(32)
    }
    
    func generateQRCode() -> UIImage {
        let data = "\(self.accountStore.id)"
        filter.message = Data(data.utf8)

        if let outputImage = filter.outputImage {
            if let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
                
//                let logo = UIImage(named: "AppLogo")
//                logo?.addToCenter(of: cgImage)
                
                return UIImage(cgImage: cgImage)
            }
        }

        return UIImage(systemName: "xmark.circle") ?? UIImage()
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
