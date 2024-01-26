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
    
    @State var showEditSheet = false
    @State var tabSelectedValue = 0
    
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
                    
                    Spacer()
                    
                    Text("Edit".uppercased())
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 24)
                                .foregroundColor(ColorConstants.primary)
                        )
                        .onTapGesture {
                            self.showEditSheet = true
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
        VStack(alignment: .leading, spacing: 12) {
            Picker("", selection: self.$tabSelectedValue) {
                Text("Permission Group".uppercased()).tag(0)
                Text("Connection Groups".uppercased()).tag(1)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 16)
            .padding(.top, 16)

            TabView(selection: $tabSelectedValue) {
                editPermissionGroup.tag(0)

                editConnectionGroups.tag(1)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeIn, value: tabSelectedValue)
        }
    }
    
    var editPermissionGroup: some View {
        VStack {
            ScrollView {
                VStack(alignment: .leading) {
                    Text("Change Permission Group")
                      .font(Font.custom("SF Pro", size: 20).weight(.medium))
                      .foregroundColor(Color(red: 0.12, green: 0.19, blue: 0.29))
                      .padding([.leading, .bottom], 16)
                    
                    ForEach(self.accountStore.permissionGroups, id: \.name) { group in
                        ZStack(alignment: .top) {
                            PermissionGroupRow(group: group)
                            
                            Spacer()
                            
                            HStack {
                                Spacer()
                                
                                if self.connectionStore.permissionGroup == group.name {
                                    Image(systemName: "checkmark")
                                        .frame(width: 28, height: 28)
                                        .foregroundColor(.white)
                                        .fontWeight(.medium)
                                        .foregroundColor(.white)
                                        .background(ColorConstants.primary)
                                        .opacity(self.connectionStore.saving ? 0.5 : 1.0)
                                        .cornerRadius(8)
                                        .fontWeight(.light)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8).stroke(ColorConstants.primary, lineWidth: 1)
                                        )
                                } else {
                                    RoundedRectangle(cornerRadius: 8).stroke(.gray, lineWidth: 1)
                                        .frame(width: 28, height: 28)
                                        .foregroundColor(ColorConstants.badgeText)
                                        .background(.white)
                                        .onTapGesture {
                                            if !self.connectionStore.saving {
                                                self.connectionStore.permissionGroup = group.name
                                                self.connectionStore.update { (result: Result<Connection, Error>) in
                                                    switch result {
                                                    case .success(let connection):
                                                        print("Updated connection with \(connection.id)")
                                                    case .failure(let error):
                                                        print("Something bad happened", error)
                                                    }
                                                }
                                            }
                                        }
                                }
                            }.padding()
                        }.padding([.leading, .trailing, .bottom])
                    }
                    .redacted(when: self.accountStore.loading, redactionType: .customPlaceholder)
                }
            }
        }
        .padding([.top], 40)
    }
    
    var editConnectionGroups: some View {
        VStack {
            ScrollView {
                VStack(alignment: .leading) {
                    Text("Select Connection Group(s)")
                      .font(Font.custom("SF Pro", size: 20).weight(.medium))
                      .foregroundColor(Color(red: 0.12, green: 0.19, blue: 0.29))
                      .padding([.leading, .bottom], 16)
                    
                    ForEach(self.connectionGroupsStore.groups, id: \.name) { group in
                        ZStack(alignment: .trailing) {
                            ConnectionGroupRow(connectionGroup: group)
                            
                            Spacer()
                            
                            if group.connections.contains(self.connectionStore.id) {
                                Image(systemName: "checkmark")
                                    .toolbarButtonStyle(bgColor: ColorConstants.primary)
                                    .foregroundColor(.white)
                                    .opacity(self.connectionGroupsStore.loading ? 0.5 : 1.0)
                                    .opacity(self.connectionGroupsStore.loading ? 0.5 : 1.0)
                                    .padding(.horizontal, 16)
                                    .onTapGesture {
                                        self.connectionGroupsStore.removeFromGroup(groupId: group.id, userId: self.connectionStore.id) { (result: Result<Bool, Error>) in
                                                switch result {
                                                    case .success(_):
                                                    self.connectionGroupsStore.load()
                                                    case .failure(let error):
                                                    print("Failed to remove from group", error)
                                                }
                                            }
                                    }
                            } else {
                                Image(systemName: "plus")
                                    .toolbarButtonStyle()
                                    .opacity(self.connectionGroupsStore.loading ? 0.5 : 1.0)
                                    .padding(.horizontal, 16)
                                    .onTapGesture {
                                        self.connectionGroupsStore.addToGroup(groupId: group.id, userId: self.connectionStore.id) { (result: Result<Bool, Error>) in
                                                switch result {
                                                    case .success(_):
                                                    self.connectionGroupsStore.load()
                                                    case .failure(let error):
                                                    print("Failed to add to group", error)
                                                }
                                            }
                                    }
                            }
                        }.padding()
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
