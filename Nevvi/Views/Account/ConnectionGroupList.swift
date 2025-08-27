//
//  ConnectionRequestList.swift
//  Nevvi
//
//  Created by Tyler Cobb on 12/31/22.
//

import SwiftUI

struct ConnectionGroupList: View {
    @EnvironmentObject var connectionGroupsStore: ConnectionGroupsStore
    @EnvironmentObject var connectionGroupStore: ConnectionGroupStore
    @EnvironmentObject var connectionsStore: ConnectionsStore
        
    @State private var newGroupName: String = ""
    @State private var newGroupConnections: [Connection] = []
    @State private var showGroupForm: Bool = false
    @State private var creatingGroup: Bool = false
    
    @State private var groupToDelete: String = ""
    @State private var showDeleteAlert: Bool = false
            
    var body: some View {
        VStack(alignment: .center) {
            if self.creatingGroup {
                creatingView
            } else if self.connectionGroupsStore.loading {
                loadingView
            } else if self.connectionGroupsStore.groupsCount == 0 {
                noGroupsView
            } else {
                groupsView
            }
        }
        .refreshable {
            self.connectionGroupsStore.load()
        }
        .sheet(isPresented: self.$showGroupForm) {
            newGroupSheet
        }
        .alert(isPresented: self.$showDeleteAlert) {
            deleteAlert
        }
    }
    
    var newGroupButton: some View {
        HStack {
            Button {
                self.showGroupForm = true
            } label: {
                Text("New Connection Group".uppercased())
                    .frame(maxWidth: .infinity)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .foregroundColor(ColorConstants.primary)
                    )
            }
        }
        .padding([.horizontal], 16)
        .padding([.vertical], 20)
    }
    
    var creatingView: some View {
        VStack {
            Spacer()
            LoadingView(loadingText: "Creating group...")
            Spacer()
            Spacer()
        }
    }
    
    var loadingView: some View {
        VStack {
            Spacer()
            LoadingView(loadingText: "Loading groups...")
            Spacer()
            Spacer()
        }
    }
    
    var noGroupsView: some View {
        VStack {
            Spacer()
            HStack(alignment: .center) {
                VStack(alignment: .center, spacing: 24) {
                    Image("UpdateProfile")
                    
                    Text("No connection groups")
                        .defaultStyle(size: 24, opacity: 1.0)
                }
                .padding()
            }
            Spacer()
            Spacer()
            newGroupButton
        }
    }
    
    var groupsView: some View {
        VStack {
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(self.connectionGroupsStore.groups, id: \.id) { group in
                        ZStack(alignment: .trailing) {
                            NavigationLink {
                                NavigationLazyView(
                                    ConnectionGroupDetail()
                                        .onAppear {
                                            self.connectionGroupStore.load(group: group)
                                        }
                                )
                            } label: {
                                ConnectionGroupRow(connectionGroup: group)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "trash")
                                .toolbarButtonStyle()
                                .onTapGesture {
                                    self.groupToDelete = group.id
                                    self.showDeleteAlert = true
                                }
                                .padding()
                        }.padding([.leading, .trailing, .bottom])
                    }
                    .redacted(when: self.connectionGroupsStore.loading || self.connectionGroupsStore.deleting || self.connectionGroupsStore.creating, redactionType: .customPlaceholder)
                }
            }
            
            Spacer()
            
            newGroupButton
        }
    }
    
    var deleteAlert: Alert {
        Alert(title: Text("Delete confirmation"), message: Text("Are you sure you want to delete this group?"), primaryButton: .destructive(Text("Delete")) {

            self.connectionGroupsStore.delete(groupId: self.groupToDelete) { (result: Result<Bool, Error>) in
                switch result {
                case .success(_):
                    self.connectionGroupsStore.load()
                case .failure(let error):
                    print("Failed to delete group", error)
                }
            }
            self.showDeleteAlert = false
        }, secondaryButton: .cancel() {
            self.showDeleteAlert = false
        })
    }
    
    var newGroupSheet: some View {
        VStack {
            TextField("Group Name", text: self.$newGroupName)
                .padding()
                .overlay(RoundedRectangle(cornerRadius: 16.0).strokeBorder(Color.secondary, style: StrokeStyle(lineWidth: 1.0)))
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
                .padding([.top, .horizontal])
                .disabled(self.creatingGroup)
            
            Divider().padding(.vertical)
            
            Spacer()
            
            HStack {
                Text("Add Members")
                    .fontWeight(.light)
                    .padding([.top, .bottom], 6)
                
                Spacer()
            }
            .padding([.horizontal], 18)
                
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(self.connectionsStore.connections) { connection in
                        ZStack(alignment: .trailing) {
                            ConnectionRow(connection: connection)
                            
                            Spacer()
                            
                            if self.isConnectionSelected(connection: connection) {
                                Image(systemName: "checkmark")
                                    .toolbarButtonStyle(bgColor: ColorConstants.primary)
                                    .foregroundColor(.white)
                                    .opacity(self.creatingGroup ? 0.5 : 1.0)
                                    .padding(.trailing)
                                    .onTapGesture {
                                        if !creatingGroup {
                                            self.newGroupConnections.removeAll(where: { newConnection in newConnection == connection
                                            })
                                        }
                                    }
                            } else {
                                Image(systemName: "plus")
                                    .toolbarButtonStyle()
                                    .opacity(self.creatingGroup ? 0.5 : 1.0)
                                    .padding(.trailing)
                                    .onTapGesture {
                                        if !creatingGroup {
                                            self.newGroupConnections.append(connection)
                                        }
                                    }
                            }
                        }
                    }
                }
            }
            
            HStack {
                Button {
                    self.creatingGroup = true
                    self.showGroupForm = false
                    self.connectionGroupsStore.create(name: self.newGroupName) { (result: Result<ConnectionGroup, Error>) in
                        switch result {
                        case .success(let newGroup):
                            if self.newGroupConnections.isEmpty {
                                self.connectionGroupsStore.load()
                                self.creatingGroup = false
                                self.newGroupName = ""
                                self.newGroupConnections = []
                            } else {
                                // TODO - bulk add members to group
                                self.newGroupConnections.forEach { connection in
                                    self.connectionGroupsStore.addToGroup(groupId: newGroup.id, userId: connection.id) { _ in
                                        if connection == self.newGroupConnections.last {
                                            self.connectionGroupsStore.load()
                                            self.creatingGroup = false
                                            self.newGroupName = ""
                                            self.newGroupConnections = []
                                        }
                                    }
                                }
                            }
                        case .failure(let error):
                            print("Something bad happened", error)
                            self.creatingGroup = false
                            self.newGroupName = ""
                            self.newGroupConnections = []
                        }
                    }
                } label: {
                    Text("Save".uppercased())
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 24)
                                .foregroundColor(ColorConstants.primary)
                        )
                        .opacity(self.newGroupName.isEmpty || self.creatingGroup ? 0.5 : 1.0)
                }
                .disabled(self.newGroupName.isEmpty || self.creatingGroup)
            }
            .padding([.horizontal], 18)
        }
        .padding([.vertical], 12)
    }
    
    func isConnectionSelected(connection: Connection) -> Bool {
        return self.newGroupConnections.contains(connection)
    }
}

struct ConnectionGroupList_Previews: PreviewProvider {
    static let modelData = ModelData()
    static let accountStore = AccountStore(user: modelData.user)
    static let connectionGroupsStore = ConnectionGroupsStore(groups: modelData.groups)
    static let connectionGroupStore = ConnectionGroupStore(group: modelData.groups[0], connections: modelData.connectionResponse.users)
    static let connectionsStore = ConnectionsStore(connections: modelData.connectionResponse.users,
                                                   requests: modelData.requests,
                                                   blockedUsers: modelData.connectionResponse.users)
    
    static var previews: some View {
        ConnectionGroupList()
            .environmentObject(connectionGroupsStore)
            .environmentObject(connectionGroupStore)
            .environmentObject(connectionsStore)
            .environmentObject(accountStore)
    }
}
