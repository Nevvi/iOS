//
//  ConnectionDetail.swift
//  Nevvi
//
//  Created by Tyler Cobb on 12/29/22.
//

import SwiftUI

struct ConnectionDetail: View {
    @EnvironmentObject var connectionStore: ConnectionStore
    @EnvironmentObject var accountStore: AccountStore
    @EnvironmentObject var connectionGroupsStore: ConnectionGroupsStore
    
    @State var showEditSheet = true
    
    var body: some View {
        if self.connectionStore.loading == false && !self.connectionStore.id.isEmpty {
            ScrollView {
                VStack(spacing: 12) {
                    HStack(alignment: .center) {
                        Spacer()
                        VStack(alignment: .center, spacing: 4) {
                            ProfileImage(imageUrl: self.connectionStore.profileImage, height: 108, width: 108)
                            
                            Text("\(self.connectionStore.firstName) \(self.connectionStore.lastName)")
                                .defaultStyle(size: 22, opacity: 1.0)
                            
                            Text(self.connectionStore.bio)
                                .defaultStyle(size: 16, opacity: 0.6)
                        }
                        Spacer()
                    }
                    
                    HStack(alignment: .top, spacing: 8) {
                        // TODO
                        contactAction(image: "message", text: "Message")
                        contactAction(image: "phone", text: "Call")
                        contactAction(image: "envelope", text: "Mail")
                    }
                    .frame(width: .infinity, alignment: .topLeading)
                    .padding([.bottom], 16)
                    
                    if !self.connectionStore.phoneNumber.isEmpty {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Phone Number").personalInfoLabel()
                            
                            HStack(alignment: .center, spacing: 8) {
                                Text(self.connectionStore.phoneNumber)
                                    .defaultStyle(size: 16, opacity: 1.0)
                                
                                Spacer()
                                
                                Text("Home").asDefaultBadge()
                            }
                            .padding(.horizontal, 0)
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .informationSection()
                    }
                    
                    if !self.connectionStore.email.isEmpty {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Email").personalInfoLabel()
                            
                            HStack(alignment: .center, spacing: 8) {
                                Text(self.connectionStore.email)
                                    .defaultStyle(size: 16, opacity: 1.0)
                                
                                Spacer()
                                
                                Text("Personal").asDefaultBadge()
                            }
                            .padding(.horizontal, 0)
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .informationSection()
                    }
                    
                    if !self.connectionStore.address.isEmpty {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Address").personalInfoLabel()
                            
                            HStack(alignment: .top, spacing: 8) {
                                Text(self.connectionStore.address.toString())
                                    .defaultStyle(size: 16, opacity: 1.0)
                                
                                Spacer()
                                
                                Text("Home").asDefaultBadge()
                            }
                            .padding([.vertical], 8)
                            .padding([.horizontal], 0)
                            .frame(maxWidth: .infinity, alignment: .topLeading)
                        }
                        .informationSection()
                    }
                    
                    if self.connectionStore.birthday.toString() != Date().toString() {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Birthday").personalInfoLabel()
                            
                            Text(self.connectionStore.birthday.toString())
                                .defaultStyle(size: 16, opacity: 1.0)
                                .padding([.vertical], 8)
                        }
                        .informationSection()
                    }
                }
                .padding()
            }
            .background(ColorConstants.background)
            .toolbar(content: {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Image(systemName: "square.and.arrow.up")
                        .toolbarButtonStyle()
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Image(systemName: "square.and.pencil")
                        .toolbarButtonStyle()
                        .onTapGesture {
                            self.showEditSheet = true
                        }
                }
            })
            .sheet(isPresented: self.$showEditSheet) {
                editSheet
            }
        } else  {
            ProgressView()
        }
    }
    
    var editSheet: some View {
        VStack {
            ScrollView {
                VStack(alignment: .leading) {
                    // 20/Medium
                    Text("Change Permission Group")
                      .font(Font.custom("SF Pro", size: 20).weight(.medium))
                      .foregroundColor(Color(red: 0.12, green: 0.19, blue: 0.29))
                      .padding([.leading, .bottom], 16)
                    
                    ForEach(self.accountStore.permissionGroups, id: \.name) { group in
                        PermissionGroupRow(group: group, selectable: true)
                            .padding([.leading, .trailing, .bottom])
                    }
                    .redacted(when: self.accountStore.loading, redactionType: .customPlaceholder)
                }
            }
        }
        .padding([.top], 40)
    }
    
    func contactAction(image: String, text: String) -> some View {
        VStack(alignment: .center, spacing: 8) {
            Image(systemName: image)
                .frame(width: 24, height: 24)
                .foregroundColor(ColorConstants.primary)
            
            Text(text)
                .font(Font.custom("SF Pro", size: 13).weight(.semibold))
                .multilineTextAlignment(.center)
                .foregroundColor(Color(red: 0, green: 0.07, blue: 0.17).opacity(0.6))
        }
        .padding(.horizontal, 12)
        .padding(.top, 18)
        .padding(.bottom, 12)
        .frame(maxWidth: .infinity, alignment: .center)
        .background(.white)
        .cornerRadius(12)
    }
}

struct ConnectionDetail_Previews: PreviewProvider {
    static let modelData = ModelData()
    static let accountStore = AccountStore(user: modelData.user)
    static let connectionGroupsStore = ConnectionGroupsStore(groups: modelData.groups)
    static let connectionStore = ConnectionStore(connection: modelData.connection)

    static var previews: some View {
        ConnectionDetail()
            .environmentObject(accountStore)
            .environmentObject(connectionGroupsStore)
            .environmentObject(connectionStore)
    }
}
