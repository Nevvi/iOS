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
    
    @State private var toBeDeleted: IndexSet?
    @State private var showDeleteAlert: Bool = false
    
    @State private var newGroupName: String = ""
    @State private var newGroupConnections: [Connection] = []
    @State private var showGroupForm: Bool = false
    @State private var creatingGroup: Bool = false
    
    @State private var showGroupDetails: Bool = false
        
    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack {
                    if self.connectionGroupsStore.groupsCount == 0 {
                        noGroupsView
                    } else {
                        groupsView
                    }
                }.padding([.top])
            }
            
            Spacer()
            
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
            }.padding()
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
        .alert(isPresented: self.$showDeleteAlert) {
            deleteAlert
        }
    }
    
    var noGroupsView: some View {
        HStack {
            Spacer()
            if self.connectionGroupsStore.loading {
                ProgressView()
            } else {
                NoDataFound(imageName: "person.2.slash", height: 100, width: 120)
            }
            Spacer()
        }
        .padding([.top], 100)
    }
    
    var groupsView: some View {
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
                    
                    Button {
                        
                    } label: {
                        Label("Export to CSV", systemImage: "envelope")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .frame(width: 24, height: 24)
                        .rotationEffect(.degrees(-90))
                        .foregroundColor(.gray)
                }
            }.padding([.leading, .trailing, .bottom])
        }
        .redacted(when: self.connectionGroupsStore.loading, redactionType: .customPlaceholder)
    }
    
    var deleteAlert: Alert {
        Alert(title: Text("Delete group?"), message: Text("Are you sure you want to delete this group?"), primaryButton: .destructive(Text("Delete")) {
                for index in self.toBeDeleted! {
                    let groupId = self.connectionGroupsStore.groups[index].id
                    self.connectionGroupsStore.delete(groupId: groupId) { (result: Result<Bool, Error>) in
                        switch result {
                        case.success(_):
                            self.connectionGroupsStore.load()
                        case .failure(let error):
                            print("Something bad happened", error)
                        }
                    }
                }
                
                self.toBeDeleted = nil
                self.showDeleteAlert = false
            }, secondaryButton: .cancel() {
                self.toBeDeleted = nil
                self.showDeleteAlert = false
            }
        )
    }
    
    var newGroupSheet: some View {
        VStack {
            TextField("Group Name", text: self.$newGroupName)
                .padding()
                .overlay(RoundedRectangle(cornerRadius: 16.0).strokeBorder(Color.secondary, style: StrokeStyle(lineWidth: 1.0)))
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
                .padding([.top])
                .disabled(self.creatingGroup)
            
            Divider().padding(.vertical)
            
            Spacer()
            
            VStack {
                HStack {
                    Text("Add Members")
                        .fontWeight(.light)
                        .padding([.top, .bottom], 6)
                    
                    Spacer()
                }
                
                ScrollView {
                    ForEach(self.connectionsStore.connections) { connection in
                        ZStack(alignment: .trailing) {
                            ConnectionRow(connection: connection)
                            
                            Spacer()
                            
                            if self.isConnectionSelected(connection: connection) {
                                Image(systemName: "checkmark")
                                    .toolbarButtonStyle(bgColor: ColorConstants.primary)
                                    .foregroundColor(.white)
                                    .opacity(self.creatingGroup ? 0.5 : 1.0)
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
                        .opacity(self.newGroupName.isEmpty ? 0.5 : 1.0)
                }
                .disabled(self.newGroupName.isEmpty)
            }
        }
        .padding([.vertical], 12)
        .padding([.horizontal], 18)
    }
    
    func delete(at offsets: IndexSet) {
        self.toBeDeleted = offsets
        self.showDeleteAlert = true
        print(offsets)
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
