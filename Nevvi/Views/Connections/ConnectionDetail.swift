//
//  ConnectionDetail.swift
//  Nevvi
//
//  Created by Tyler Cobb on 12/29/22.
//

import SwiftUI

struct ConnectionDetail: View {    
    @EnvironmentObject var accountStore: AccountStore
    @EnvironmentObject var connectionGroupsStore: ConnectionGroupsStore
    
    @ObservedObject var connectionStore: ConnectionStore
    
    @State var showEditSheet = false
    
    var body: some View {
        if self.connectionStore.loading == false && !self.connectionStore.id.isEmpty {
            VStack {
                VStack {
                    ProfileImage(imageUrl: self.connectionStore.profileImage, height: 100, width: 100)
                    Text("\(self.connectionStore.firstName) \(self.connectionStore.lastName)")
                }.padding()
                
                VStack {
                    if !self.connectionStore.email.isEmpty {
                        connectionData(label: "Email", value: self.connectionStore.email)
                    }
                    
                    if !self.connectionStore.phoneNumber.isEmpty {
                        connectionData(label: "Phone Number", value: self.connectionStore.phoneNumber)
                    }
                    
                    if !self.connectionStore.address.isEmpty {
                        connectionData(label: "Address", value: self.connectionStore.address.toString())
                    }
                    
                    if self.connectionStore.birthday.toString() != Date().toString() {
                        connectionData(label: "Birthday", value: self.connectionStore.birthday.toString())
                    }
                }.padding()
                
                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: {
                editButton
            })
            .sheet(isPresented: self.$showEditSheet) {
                editSheet
            }
        } else  {
            ProgressView()
        }
    }
    
    var editButton: some View {
        Button {
            self.showEditSheet = true
        } label: {
            Text("Edit")
        }
    }
    
    var editSheet: some View {
        VStack {
            ProfileImage(imageUrl: self.connectionStore.profileImage, height: 80, width: 80)
            
            Text("\(self.connectionStore.firstName) \(self.connectionStore.lastName)")
                .font(.title2)
                .fontWeight(.semibold)
            
            Divider().padding([.top, .bottom], 20)
            
            VStack {
                Text("Permission Group")
                    .personalInfoLabel()
                
                Menu {
                    Picker("Which permission group should \(self.connectionStore.firstName) belong to?", selection: self.$connectionStore.permissionGroup) {
                        ForEach(self.accountStore.permissionGroups, id: \.name) {
                            Text($0.name.uppercased())
                        }
                    }
                } label: {
                    Text(self.connectionStore.permissionGroup.uppercased())
                        .font(.system(size: 18))
                        .fontWeight(.semibold)
                        .foregroundColor(ColorConstants.secondary)
                        .opacity(self.connectionStore.saving ? 0.5 : 1.0)
                        .frame(width: 500)
                }
            }
            .disabled(self.connectionStore.saving)
            .onChange(of: self.connectionStore.permissionGroup) { newValue in
                self.connectionStore.update { (result: Result<Connection, Error>) in
                    switch result {
                    case .success(let connection):
                        print("Updated connection with \(connection.id)")
                    case .failure(let error):
                        print("Something bad happened", error)
                    }
                }
            }
            
            Divider().padding([.top, .bottom], 20)
            
            VStack {
                Text("Group Membership")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .padding([.bottom], 5)
                    
                                            
                ForEach(self.connectionGroupsStore.groups, id: \.name) { group in
                    ConnectionGroupMembershipRow(connectionStore: self.connectionStore,
                                                 isMember: group.connections.contains(self.connectionStore.id),
                                                 group: group)
                }
                .padding([.leading, .trailing])
                .padding([.bottom], 5)
            }
            
            Spacer()
        }
        .padding([.top], 40)
        .padding([.leading, .trailing], 20)
    }
    
    func connectionData(label: String, value: String) -> some View {
        VStack(alignment: .leading) {
            Text(label).personalInfoLabel()
            Text(value).personalInfo()
                .contextMenu {
                    Button(action: {
                        UIPasteboard.general.string = value
                    }) {
                        Text("Copy")
                        Image(systemName: "doc.on.doc")
                    }
                 }
        }
        .padding([.leading, .trailing])
        .padding([.bottom], 10)
    }
}

struct ConnectionDetail_Previews: PreviewProvider {
    static let modelData = ModelData()
    static let accountStore = AccountStore(user: modelData.user)
    static let connectionGroupsStore = ConnectionGroupsStore(groups: modelData.groups)
    static let connectionStore = ConnectionStore(connection: modelData.connection)

    static var previews: some View {
        ConnectionDetail(connectionStore: connectionStore)
            .environmentObject(accountStore)
            .environmentObject(connectionGroupsStore)
    }
}
