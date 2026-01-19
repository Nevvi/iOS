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
    @State private var searchText: String = ""
    
    @State private var groupToDelete: String = ""
    @State private var showDeleteAlert: Bool = false
    
    private var filteredConnections: [Connection] {
        return self.connectionsStore.connections
    }
            
    var body: some View {
        NavigationView {
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
            .toolbar(content: {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Image(systemName: "plus")
                        .toolbarButtonStyle()
                        .onTapGesture {
                            self.showGroupForm = true
                        }
                }
            })
            .navigationTitle("Connection Groups")
            .navigationBarTitleDisplayMode(.inline)
        }
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
            
        }
        .padding(.top)
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
        VStack(spacing: 0) {
            // Header
            VStack(alignment: .leading, spacing: 24) {
                Text("Create New Group")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 8)
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Group Name")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    TextField("Enter group name", text: self.$newGroupName)
                        .textFieldStyle(.plain)
                        .font(.body)
                        .textInputAutocapitalization(.words)
                        .disableAutocorrection(false)
                        .disabled(self.creatingGroup)
                        .opacity(self.creatingGroup ? 0.6 : 1.0)
                }
            }
            .padding(.horizontal, 20)
            
            Divider()
                .padding(.vertical, 16)
            
            // Members Section
            VStack(alignment: .leading, spacing: 16) {
                // Search field
                VStack(alignment: .leading, spacing: 16) {
                    Text("Search Connections")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .padding(.horizontal, 20)
                    
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        
                        TextField("Search by name", text: self.$searchText)
                            .textFieldStyle(.plain)
                            .font(.body)
                            .textInputAutocapitalization(.never)
                            .disableAutocorrection(true)
                            .disabled(self.creatingGroup)
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
                    .padding(.horizontal, 20)
                    .opacity(self.creatingGroup ? 0.6 : 1.0)
                }
                
                Divider()
                
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("Add Members")
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
                    .padding(.horizontal, 20)
                }
            }
            
            if self.connectionsStore.loading {
                VStack {
                    Spacer()
                    LoadingView(loadingText: "Searching connections...")
                    Spacer()
                }
                .frame(minHeight: 200)
            } else if self.filteredConnections.isEmpty && !searchText.isEmpty {
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
            } else if self.filteredConnections.isEmpty && searchText.isEmpty {
                // Empty state - no connections
                VStack(spacing: 20) {
                    Spacer()
                    
                    Image(systemName: "person.3.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.secondary.opacity(0.6))
                    
                    VStack(spacing: 8) {
                        Text("No Connections")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        Text("Add some connections to include them in groups")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                    
                    Spacer()
                    Spacer()
                }
            } else {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 0) {
                        ForEach(self.filteredConnections) { connection in
                            ZStack(alignment: .trailing) {
                                ConnectionRow(connection: connection)
                                
                                Spacer()
                                
                                if self.isConnectionSelected(connection: connection) {
                                    Button(action: {
                                        if !creatingGroup {
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
                                    .disabled(self.creatingGroup)
                                    .opacity(self.creatingGroup ? 0.5 : 1.0)
                                    .padding(.trailing, 16)
                                } else {
                                    Button(action: {
                                        if !creatingGroup {
                                            self.newGroupConnections.append(connection)
                                        }
                                    }) {
                                        Image(systemName: "plus.circle")
                                            .font(.title2)
                                            .foregroundColor(.secondary)
                                    }
                                    .disabled(self.creatingGroup)
                                    .opacity(self.creatingGroup ? 0.5 : 1.0)
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
            }
            
            Spacer()
            
            // Bottom action area
            VStack(spacing: 16) {
                Divider()
                
                VStack(spacing: 12) {
                    // Summary text
                    if !self.newGroupConnections.isEmpty {
                        Text("Creating group with \(self.newGroupConnections.count) member\(self.newGroupConnections.count == 1 ? "" : "s")")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack(spacing: 12) {
                        // Cancel button
                        Button {
                            self.showGroupForm = false
                            self.newGroupName = ""
                            self.newGroupConnections = []
                            self.searchText = ""
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
                        .disabled(self.creatingGroup)
                        
                        // Create button
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
                                        self.searchText = ""
                                    } else {
                                        // TODO - bulk add members to group
                                        self.newGroupConnections.forEach { connection in
                                            self.connectionGroupsStore.addToGroup(groupId: newGroup.id, userId: connection.id) { _ in
                                                if connection == self.newGroupConnections.last {
                                                    self.connectionGroupsStore.load()
                                                    self.creatingGroup = false
                                                    self.newGroupName = ""
                                                    self.newGroupConnections = []
                                                    self.searchText = ""
                                                }
                                            }
                                        }
                                    }
                                case .failure(let error):
                                    print("Something bad happened", error)
                                    self.creatingGroup = false
                                    self.newGroupName = ""
                                    self.newGroupConnections = []
                                    self.searchText = ""
                                }
                            }
                        } label: {
                            HStack {
                                if self.creatingGroup {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                }
                                
                                Text(self.creatingGroup ? "Creating..." : "Create Group")
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
                            .opacity(self.newGroupName.isEmpty || self.creatingGroup ? 0.6 : 1.0)
                        }
                        .disabled(self.newGroupName.isEmpty || self.creatingGroup)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 8)
            }
        }
        .onAppear {
            self.connectionsStore.load(nameFilter: nil, permissionGroup: nil)
            self.searchText = ""
            self.newGroupConnections = []
        }
    }
    
    func isConnectionSelected(connection: Connection) -> Bool {
        return self.newGroupConnections.contains(connection)
    }
}

struct ConnectionGroupList_Previews: PreviewProvider {
    static let modelData = ModelData()
    static let accountStore = AccountStore(user: modelData.user)
    static let connectionGroupsStore = ConnectionGroupsStore(groups: modelData.groups)
    static let connectionGroupStore = ConnectionGroupStore(group: modelData.groups[0], connections: modelData.connectionResponse.users, invitedContacts: [ContactStore.ContactInfo(firstName: "John", lastName: "Doe", phoneNumber: "6129631237")])
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
