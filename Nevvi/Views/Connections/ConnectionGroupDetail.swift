//
//  ConnectionGroupDetail.swift
//  Nevvi
//
//  Created by Tyler Cobb on 1/9/23.
//

import AlertToast
import SwiftUI

struct ConnectionGroupDetail: View {
    @EnvironmentObject var accountStore: AccountStore
    @EnvironmentObject var connectionsStore: ConnectionsStore
    @EnvironmentObject var connectionGroupStore: ConnectionGroupStore
    @EnvironmentObject var connectionGroupsStore: ConnectionGroupsStore
        
    @State private var showToast: Bool = false
    @State private var showAddUsers: Bool = false
    @State private var savingUsers: Bool = false
    @State private var newGroupConnections: [Connection] = []
    
    private var possibleConnections: [Connection] {
        return self.connectionsStore.connections.filter { connection in
            return !self.connectionGroupStore.isConnectionInGroup(connection: connection)
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center, spacing: 8) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("\(self.connectionGroupStore.name)")
                        .defaultStyle(size: 20, opacity: 1.0)
                    
                    Text("Members (\(self.connectionGroupStore.connectionCount))")
                        .defaultStyle(size: 16, opacity: 0.6)
                        .redacted(when: self.connectionGroupStore.loadingConnections || self.connectionGroupStore.deleting, redactionType: .customPlaceholder)
                }
                
                Spacer()
                
                Menu {
                    Button {
                        self.connectionsStore.load(nameFilter: nil, permissionGroup: nil)
                        self.showAddUsers = true
                    } label: {
                        Label("Add Members", systemImage: "plus.circle")
                    }
                    
                    Button {
                        self.connectionGroupStore.exportGroupData { (result: Result<Bool, Error>) in
                            switch result {
                            case .success(_):
                                self.showToast = true
                            case .failure(let error):
                                print("Failed to export", error)
                            }
                        }
                    } label: {
                        Label("Export to CSV", systemImage: "envelope")
                    }
                    
                } label: {
                    Image(systemName: "ellipsis")
                        .frame(width: 24, height: 24)
                        .rotationEffect(.degrees(-90))
                        .foregroundColor(.gray)
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .overlay(
                Rectangle()
                    .inset(by: 0.5)
                    .stroke(Color(red: 0, green: 0.07, blue: 0.17).opacity(0.08), lineWidth: 1)
            )
                        
            VStack(alignment: .trailing, spacing: 0) {
                if self.connectionGroupStore.loading || self.connectionGroupStore.connectionCount == 0 {
                    Spacer()
                    noConnectionsView
                    Spacer()
                } else {
                    connectionsView
                }
            }
        }
        .padding(.top)
        .refreshable {
            self.connectionGroupStore.loadConnections()
        }
        .navigationTitle(self.connectionGroupStore.name)
        .navigationBarTitleDisplayMode(.inline)
        .toast(isPresenting: $showToast){
            AlertToast(displayMode: .banner(.slide), type: .complete(Color.green), title: "Export sent to \(self.accountStore.email)")
        }
        .sheet(isPresented: self.$showAddUsers) {
            addUsersSheet
        }
    }
    
    var noConnectionsView: some View {
        HStack(alignment: .center) {
            if self.connectionGroupStore.loadingConnections {
                ProgressView()
            } else {
                VStack(alignment: .center, spacing: 24) {
                    Image("UpdateProfile")
                    
                    Text("No connections")
                        .defaultStyle(size: 24, opacity: 1.0)
                }
                .padding()
            }
        }
    }
    
    var connectionsView: some View {
        VStack(spacing: 0) {
            ScrollView(.vertical) {
                VStack(alignment: .trailing, spacing: 0) {
                    ForEach(self.connectionGroupStore.connections) { connection in
                        GroupConnectionRow(connection: connection, connectionGroupStore: self.connectionGroupStore)
                    }
                    .redacted(when: self.connectionGroupStore.loadingConnections || self.connectionGroupStore.deleting, redactionType: .customPlaceholder)
                }
                .frame(maxWidth: .infinity, alignment: .topTrailing)
            }
        }
    }
    
    var addUsersSheet: some View {
        VStack {
            HStack {
                Text("Add Members")
                    .fontWeight(.light)
                    .padding([.top, .bottom], 6)
                
                Spacer()
            }
            .padding([.horizontal], 18)
                
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(self.possibleConnections) { connection in
                        ZStack(alignment: .trailing) {
                            ConnectionRow(connection: connection)
                            
                            Spacer()
                            
                            if self.isConnectionSelected(connection: connection) {
                                Image(systemName: "checkmark")
                                    .toolbarButtonStyle(bgColor: ColorConstants.primary)
                                    .foregroundColor(.white)
                                    .opacity(self.savingUsers ? 0.5 : 1.0)
                                    .padding(.trailing)
                                    .onTapGesture {
                                        if !savingUsers {
                                            self.newGroupConnections.removeAll(where: { newConnection in newConnection == connection
                                            })
                                        }
                                    }
                            } else {
                                Image(systemName: "plus")
                                    .toolbarButtonStyle()
                                    .opacity(self.savingUsers ? 0.5 : 1.0)
                                    .padding(.trailing)
                                    .onTapGesture {
                                        if !savingUsers {
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
                    if self.newGroupConnections.isEmpty {
                        self.newGroupConnections = []
                        self.connectionGroupsStore.load()
                        self.showAddUsers = false
                        return
                    }
                    
                    // TODO - bulk add members to group
                    self.savingUsers = true
                    self.newGroupConnections.forEach { connection in
                        self.connectionGroupStore.addToGroup(userId: connection.id) { _ in
                            if connection == self.newGroupConnections.last {
                                self.newGroupConnections = []
                                self.connectionGroupsStore.load()
                                self.connectionGroupStore.loadConnections()
                                self.showAddUsers = false
                                self.savingUsers = false
                            }
                        }
                    }
                } label: {
                    Text("Update".uppercased())
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 24)
                                .foregroundColor(ColorConstants.primary)
                        )
                        .opacity(self.savingUsers ? 0.5 : 1.0)
                }
                .disabled(self.savingUsers)
            }
            .padding([.horizontal], 18)
        }
        .padding([.vertical], 12)
    }
    
    func isConnectionSelected(connection: Connection) -> Bool {
        return self.newGroupConnections.contains(connection)
    }
}

struct ConnectionGroupDetail_Previews: PreviewProvider {
    static let modelData = ModelData()
    static let accountStore = AccountStore(user: modelData.user)
    static let connectionGroupStore = ConnectionGroupStore(group: modelData.groups[0], connections: [])
    static let connectionGroupsStore = ConnectionGroupsStore(groups: modelData.groups)
    static let connectionsStore = ConnectionsStore(connections: modelData.connectionResponse.users,
                                                   requests: modelData.requests,
                                                   blockedUsers: modelData.connectionResponse.users)
    
    static var previews: some View {
        ConnectionGroupDetail()
            .environmentObject(accountStore)
            .environmentObject(connectionsStore)
            .environmentObject(connectionGroupStore)
            .environmentObject(connectionGroupsStore)
    }
}
