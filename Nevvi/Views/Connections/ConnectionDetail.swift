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
    
    @State var showGroups = false
    @State var showSettings = false
    
    var body: some View {
        if self.connectionStore.loading == false && !self.connectionStore.id.isEmpty {
            ScrollView {
                VStack {
                    ProfileImage(imageUrl: self.connectionStore.profileImage, height: 100, width: 100)
                    Text("\(self.connectionStore.firstName) \(self.connectionStore.lastName)")
                }.padding()
                
                if !self.connectionStore.email.isEmpty {
                    connectionData(label: "Email", value: self.connectionStore.email)
                }
                
                if !self.connectionStore.phoneNumber.isEmpty {
                    connectionData(label: "Phone Number", value: self.connectionStore.phoneNumber)
                }
                
                if !self.connectionStore.address.isEmpty {
                    connectionData(label: "Address", value: self.connectionStore.address.toString())
                }
                
                if self.connectionStore.birthday.yyyyMMdd() != Date().yyyyMMdd() {
                    connectionData(label: "Birthday", value: self.connectionStore.birthday.yyyyMMdd())
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: settingsButton)
            .navigationBarItems(trailing: groupsButton)
            .sheet(isPresented: self.$showSettings) {
                settingsSheet
            }
            .sheet(isPresented: self.$showGroups) {
                groupsSheet
            }
        } else  {
            ProgressView()
        }
    }
    
    var settingsButton: some View {
        Button {
            self.showSettings = true
        } label: {
            Image(systemName: "gearshape.fill")
                .renderingMode(.template)
                .foregroundColor(.black)
        }
    }
    
    var groupsButton: some View {
        Button {
            self.showGroups = true
        } label: {
            Image(systemName: "person.3.fill")
                .renderingMode(.template)
                .foregroundColor(.black)
        }
    }
    
    var groupsSheet: some View {
        VStack {
            Text("Group Membership")
                .font(.title3)
                .fontWeight(.semibold)
                .padding([.top], 50)
                                        
            List {
                ForEach(self.connectionGroupsStore.groups, id: \.name) { group in
                    ConnectionGroupMembershipRow(connectionStore: self.connectionStore,
                                                 isMember: group.connections.contains(self.connectionStore.id),
                                                 group: group)
                }
                .listRowSeparator(.hidden)
            }
            .scrollContentBackground(.hidden)
            .padding([.top], -30)
            .presentationDetents([.fraction(0.50)])
        }
    }
    
    var settingsSheet: some View {
        ZStack {
            VStack {
                Text("Your settings with \(self.connectionStore.firstName)")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding([.top], 50)
                    .padding([.bottom], 20)
                
                Spacer()
                
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
                            .foregroundColor(self.connectionStore.saving ? .gray : Color(UIColor(hexString: "#49C5B6")))
                            .frame(width: 500)
                    }
                }
                
                Spacer()
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
        }
        .presentationDetents([.fraction(0.33)])
    }
    
    func connectionData(label: String, value: String) -> some View {
        VStack(alignment: .leading) {
            Text(label).personalInfoLabel()
            Text(value).asTextField()
        }.personalInfoStyle()
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
