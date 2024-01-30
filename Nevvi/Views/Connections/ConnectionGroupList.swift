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
    
    @State private var showGroupDetails: Bool = false
        
    var body: some View {
        VStack(alignment: .center) {
            if self.connectionGroupsStore.groupsCount == 0 {
                noGroupsView
            } else {
                groupsView
            }
        }
        .refreshable {
            self.connectionGroupsStore.load()
        }
        .sheet(isPresented: self.$showGroupDetails, content: {
            ConnectionGroupDetail()
        })
        .sheet(isPresented: self.$showGroupForm) {
            newGroupSheet
        }
    }
    
    var newGroupButton: some View {
        HStack {
            Button {
                self.showGroupForm = true
            } label: {
                Text("New Connection Group".uppercased())
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .font(.headline)
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
    
    var noGroupsView: some View {
        VStack {
            Spacer()
            HStack(alignment: .center) {
                if self.connectionGroupsStore.loading {
                    ProgressView()
                } else {
                    VStack(alignment: .center, spacing: 24) {
                        Image("UpdateProfile")
                        
                        Text("No connection groups")
                            .defaultStyle(size: 24, opacity: 1.0)
                    }
                    .padding()
                }
            }
            Spacer()
            newGroupButton
        }
    }
    
    var groupsView: some View {
        VStack {
            ScrollView {
                ForEach(self.connectionGroupsStore.groups, id: \.id) { group in
                    ZStack(alignment: .trailing) {
                        ConnectionGroupRow(connectionGroup: group)
                            .onTapGesture {
                                self.connectionGroupStore.load(group: group)
                                self.showGroupDetails = true
                            }
                        
                        Spacer()
                        
                        Menu {
                            Button(role: .destructive) {
                                self.connectionGroupsStore.delete(groupId: group.id) { (result: Result<Bool, Error>) in
                                    switch result {
                                    case .success(_):
                                        self.connectionGroupsStore.load()
                                    case .failure(let error):
                                        print("Failed to delete group", error)
                                    }
                                }
                            } label: {
                                Label("Delete Group", systemImage: "trash")
                            }
                            .disabled(self.connectionGroupsStore.deleting)
                            
                            Button {
                                
                            } label: {
                                Label("Export to CSV", systemImage: "envelope")
                            }
                        } label: {
                            Image(systemName: "ellipsis")
                                .frame(width: 24, height: 24)
                                .rotationEffect(.degrees(-90))
                                .foregroundColor(.gray)
                                .padding(.trailing)
                        }
                    }.padding([.leading, .trailing, .bottom])
                }
                .redacted(when: self.connectionGroupsStore.loading || self.connectionGroupsStore.deleting, redactionType: .customPlaceholder)
            }
            
            Spacer()
            
            newGroupButton
        }
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
                    self.connectionGroupsStore.create(name: self.newGroupName) { (result: Result<ConnectionGroup, Error>) in
                        switch result {
                        case .success(let newGroup):
                            // TODO - bulk add members to group
                            self.newGroupConnections.forEach { connection in
                                self.connectionGroupsStore.addToGroup(groupId: newGroup.id, userId: connection.id) { _ in
                                    if connection == self.newGroupConnections.last {
                                        self.showGroupForm = false
                                        self.creatingGroup = false
                                        self.newGroupName = ""
                                        self.newGroupConnections = []
                                        self.connectionGroupsStore.load()
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
