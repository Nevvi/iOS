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
    @EnvironmentObject var connectionStore: ConnectionStore
    @EnvironmentObject var connectionsStore: ConnectionsStore
    @EnvironmentObject var connectionGroupStore: ConnectionGroupStore
    @EnvironmentObject var connectionGroupsStore: ConnectionGroupsStore
        
    @State private var showToast: Bool = false
    @State private var showAddUsers: Bool = false
    @State private var savingUsers: Bool = false
    @State private var newGroupConnections: [Connection] = []
    @State private var searchText: String = ""
    
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
                        self.searchText = ""
                        self.newGroupConnections = []
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
                if self.connectionGroupStore.exporting {
                    exportingView
                } else if self.connectionGroupStore.loading {
                    loadingView
                } else if (self.connectionGroupStore.connectionCount == 0) {
                    noConnectionsView
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
    
    var exportingView: some View {
        VStack {
            Spacer()
            LoadingView(loadingText: "Exporting connections...")
            Spacer()
            Spacer()
        }
    }
    
    var loadingView: some View {
        VStack {
            Spacer()
            LoadingView(loadingText: "Loading connections...")
            Spacer()
            Spacer()
        }
    }
    
    var noConnectionsView: some View {
        VStack(alignment: .center, spacing: 24) {
            Spacer()
            Image("UpdateProfile")
            
            Text("No connections")
                .defaultStyle(size: 24, opacity: 1.0)
            Spacer()
            Spacer()
        }
        .padding()
    }
    
    var connectionsView: some View {
        VStack(spacing: 0) {
            ScrollView(.vertical) {
                VStack(alignment: .trailing, spacing: 0) {
                    ForEach(self.connectionGroupStore.connections) { connection in
                        NavigationLink {
                            NavigationLazyView(
                                ConnectionDetail()
                                    .onAppear {
                                        loadConnection(connectionId: connection.id)
                                    }
                            )
                        } label: {
                            GroupConnectionRow(connection: connection, connectionGroupStore: self.connectionGroupStore)
                        }
                    }
                    .redacted(when: self.connectionGroupStore.loadingConnections || self.connectionGroupStore.deleting, redactionType: .customPlaceholder)
                }
                .frame(maxWidth: .infinity, alignment: .topTrailing)
            }
        }
    }
    
    var addUsersSheet: some View {
        VStack(spacing: 0) {
            // Header
            VStack(alignment: .leading, spacing: 24) {
                Text("Add Members")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 8)
                
                VStack(alignment: .leading, spacing: 16) {
                    // Search field
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Search Connections")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.secondary)
                            
                            TextField("Search by name", text: self.$searchText)
                                .textFieldStyle(.plain)
                                .font(.body)
                                .textInputAutocapitalization(.never)
                                .disableAutocorrection(true)
                                .disabled(self.savingUsers)
                                .submitLabel(.search)
                                .onSubmit {
                                    // Trigger search when user hits return
                                    if !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                        self.connectionsStore.load(nameFilter: searchText, permissionGroup: nil)
                                    }
                                }
                            
                            if !searchText.isEmpty {
                                Button(action: {
                                    searchText = ""
                                    // Reload all connections when clearing search
                                    self.connectionsStore.load(nameFilter: nil, permissionGroup: nil)
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.secondary)
                                }
                                .padding(.trailing, 12)
                            }
                        }
                        .opacity(self.savingUsers ? 0.6 : 1.0)
                    }
                    
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Available Connections")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            if !self.newGroupConnections.isEmpty {
                                Text("\(self.newGroupConnections.count) selected")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            
            // Content area
            if self.connectionsStore.loading {
                // Loading state
                VStack {
                    Spacer()
                    LoadingView(loadingText: "Searching connections...")
                    Spacer()
                }
                .frame(minHeight: 200)
            } else if self.possibleConnections.isEmpty && !searchText.isEmpty {
                // No search results
                VStack(spacing: 20) {
                    Spacer()
                    
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 60))
                        .foregroundColor(.secondary.opacity(0.6))
                    
                    VStack(spacing: 8) {
                        Text("No Results Found")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        Text("No connections found for '\(searchText)'. Try a different search term or check spelling.")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                    
                    Spacer()
                    Spacer()
                }
            } else if self.possibleConnections.isEmpty && searchText.isEmpty {
                // Empty state - all connections added
                VStack(spacing: 20) {
                    Spacer()
                    
                    Image(systemName: "person.3.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.secondary.opacity(0.6))
                    
                    VStack(spacing: 8) {
                        Text("All Connections Added")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        Text("All your connections are already members of this group")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                    
                    Spacer()
                    Spacer()
                }
            } else {
                // Connections list
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 0) {
                        ForEach(self.possibleConnections) { connection in
                            ZStack(alignment: .trailing) {
                                ConnectionRow(connection: connection)
                                
                                Spacer()
                                
                                if self.isConnectionSelected(connection: connection) {
                                    Button(action: {
                                        if !savingUsers {
                                            self.newGroupConnections.removeAll(where: { newConnection in newConnection == connection
                                            })
                                        }
                                    }) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.title2)
                                            .foregroundColor(ColorConstants.primary)
                                            .background(
                                                Circle()
                                                    .fill(Color.white)
                                                    .frame(width: 22, height: 22)
                                            )
                                    }
                                    .disabled(self.savingUsers)
                                    .opacity(self.savingUsers ? 0.5 : 1.0)
                                    .padding(.trailing, 16)
                                } else {
                                    Button(action: {
                                        if !savingUsers {
                                            self.newGroupConnections.append(connection)
                                        }
                                    }) {
                                        Image(systemName: "plus.circle")
                                            .font(.title2)
                                            .foregroundColor(.secondary)
                                    }
                                    .disabled(self.savingUsers)
                                    .opacity(self.savingUsers ? 0.5 : 1.0)
                                    .padding(.trailing, 16)
                                }
                            }
                            .background(
                                RoundedRectangle(cornerRadius: 0)
                                    .fill(self.isConnectionSelected(connection: connection) ? ColorConstants.primary.opacity(0.1) : Color.clear)
                            )
                        }
                    }
                    .padding(.vertical, 8)
                }
                .background(Color(.systemGroupedBackground))
            }
            
            Spacer()
            
            // Bottom action area
            VStack(spacing: 16) {
                Divider()
                
                VStack(spacing: 12) {
                    // Summary text
                    if !self.newGroupConnections.isEmpty {
                        Text("Adding \(self.newGroupConnections.count) member\(self.newGroupConnections.count == 1 ? "" : "s") to group")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack(spacing: 12) {
                        // Cancel button
                        Button {
                            self.showAddUsers = false
                            self.newGroupConnections = []
                        } label: {
                            Text("Cancel")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .font(.body)
                                .foregroundColor(ColorConstants.primary)
                                .padding(.vertical, 16)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .strokeBorder(ColorConstants.primary, lineWidth: 1.5)
                                        .background(Color.clear)
                                )
                        }
                        .disabled(self.savingUsers)
                        
                        // Add/Done button
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
                            HStack {
                                if self.savingUsers {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                }
                                
                                Text(self.savingUsers ? "Adding..." : self.possibleConnections.isEmpty ? "Done" : "Add Members")
                                    .fontWeight(.semibold)
                                    .font(.body)
                            }
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.white)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(ColorConstants.primary)
                                    .shadow(color: ColorConstants.primary.opacity(0.3), radius: 4, x: 0, y: 2)
                            )
                            .opacity(self.savingUsers ? 0.6 : 1.0)
                        }
                        .disabled(self.savingUsers)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 8)
            }
        }
        .background(Color(.systemGroupedBackground))
    }
    
    func isConnectionSelected(connection: Connection) -> Bool {
        return self.newGroupConnections.contains(connection)
    }
    
    func loadConnection(connectionId: String) {
        self.connectionStore.load(connectionId: connectionId) { (result: Result<Connection, Error>) in
            switch result {
            case .success(_):
                print("Got connection \(connectionId)")
            case .failure(let error):
                print("Something bad happened", error)
            }
        }
    }
}

struct ConnectionGroupDetail_Previews: PreviewProvider {
    static let modelData = ModelData()
    static let connectionStore = ConnectionStore()
    static let accountStore = AccountStore(user: modelData.user)
    static let connectionGroupStore = ConnectionGroupStore(group: modelData.groups[0], connections: [])
    static let connectionGroupsStore = ConnectionGroupsStore(groups: modelData.groups)
    static let connectionsStore = ConnectionsStore(connections: modelData.connectionResponse.users,
                                                   requests: modelData.requests,
                                                   blockedUsers: modelData.connectionResponse.users)
    
    static var previews: some View {
        ConnectionGroupDetail()
            .environmentObject(accountStore)
            .environmentObject(connectionStore)
            .environmentObject(connectionsStore)
            .environmentObject(connectionGroupStore)
            .environmentObject(connectionGroupsStore)
    }
}
