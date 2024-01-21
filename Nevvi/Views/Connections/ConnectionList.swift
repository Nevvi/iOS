//
//  ConnectionList.swift
//  Nevvi
//
//  Created by Tyler Cobb on 12/29/22.
//

import SwiftUI

struct ConnectionList: View {
    @EnvironmentObject var connectionsStore: ConnectionsStore
    @EnvironmentObject var accountStore: AccountStore
    @EnvironmentObject var usersStore: UsersStore
    @EnvironmentObject var contactStore: ContactStore
    @EnvironmentObject var connectionStore: ConnectionStore
    
    @State private var syncing: Bool = false
    @State private var showSyncConfirmation: Bool = false
    @State private var toBeDeleted: IndexSet?
    @State private var showDeleteAlert: Bool = false
    
    @State private var contactsToSyncCount: Int = 0
    @State private var contactUpdates: [ContactStore.ContactSyncInfo] = []
    @State private var showContactUpdates: Bool = false
    
    @StateObject var nameFilter = DebouncedText()
    @State var selectedGroup: String = "ALL"
        
    var body: some View {
        NavigationView {
            VStack {
                if self.accountStore.firstName.isEmpty {
                    profileUpdateView
                } else if self.nameFilter.text.isEmpty && self.connectionsStore.connectionCount == 0 {
                    noConnectionsView
                } else {
                    connectionsView
                }
            }
            .navigationTitle("Connections")
            .navigationBarTitleDisplayMode(.large)
        }
        .alert(isPresented: self.$showDeleteAlert) {
            deleteAlert
        }
        .sheet(isPresented: self.$showContactUpdates) {
            contactUpdatesSheet
        }
        .onAppear {
            if self.accountStore.deviceSettings.autoSync {
                self.sync(dryRun: false)
            }
        }
    }
    
    var profileUpdateView: some View {
        HStack(alignment: .center) {
            VStack(alignment: .center, spacing: 24) {
                Spacer()
                
                Image("UpdateProfile")
                
                Text("Update Your Profile")
                    .defaultStyle(size: 24, opacity: 1.0)
                
                // 16/Regular
                Text("You're almost there! Finish your profile and get the best experience with your connection members.")
                    .defaultStyle(size: 16, opacity: 0.7)
                    .multilineTextAlignment(.center)
                
                
                NavigationLink(destination: PersonalInformationEdit()) {
                    Text("Update Profile".uppercased())
                        .asPrimaryButton()
                }
                
                Spacer()
                Spacer()
            }
            .padding()
        }.padding()
    }
    
    var noConnectionsView: some View {
        HStack(alignment: .center) {
            VStack(alignment: .center, spacing: 24) {
                Spacer()
                
                Image("UpdateProfile")
                
                Text("No connections")
                    .defaultStyle(size: 24, opacity: 1.0)
                
                // 16/Regular
                Text("Let's find some people for you to connect with.")
                    .defaultStyle(size: 16, opacity: 0.7)
                    .multilineTextAlignment(.center)
                
                NavigationLink(destination: UserSearch()) {
                    Text("Find Connections".uppercased())
                        .asPrimaryButton()
                }
                
                Spacer()
                Spacer()
            }
            .padding()
        }.padding()
    }
    
    var connectionsView: some View {
        ScrollView(.vertical) {
            VStack {
                ScrollView(.horizontal) {
                    HStack(spacing: 6) {
                        ForEach(self.accountStore.permissionGroups, id: \.name) { group in
                            if group.name.uppercased() == self.selectedGroup.uppercased() {
                                Text(group.name.uppercased())
                                    .asSelectedGroupFilter()
                            } else {
                                Text(group.name.uppercased())
                                    .asGroupFilter()
                                    .onTapGesture {
                                        self.selectedGroup = group.name
                                    }
                            }
                        }
                    }
                    .padding(.vertical, 4)
                    .padding(.horizontal, 20)
                }
                
                
                VStack(alignment: .leading, spacing: 0) {
                    Text("Total Members (\(self.connectionsStore.connectionCount))")
                        .defaultStyle(size: 14, opacity: 0.4)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 6)
                        .frame(width: .infinity, alignment: .center)
                    
                    ForEach(self.connectionsStore.connections) { connection in
                        NavigationLink {
                            NavigationLazyView(
                                ConnectionDetail()
                                    .onAppear {
                                        loadConnection(connectionId: connection.id)
                                    }
                            )
                        } label: {
                            ConnectionRow(connection: connection)
                        }
                    }
                    .onDelete(perform: self.delete)
                    .redacted(when: self.connectionsStore.loading || self.connectionStore.deleting, redactionType: .customPlaceholder)
                }
                .frame(width: .infinity, alignment: .topLeading)
                
                Spacer()
            }
        }
        .navigationTitle("Connections")
        .navigationBarTitleDisplayMode(.large)
        .searchable(text: self.$nameFilter.text)
        .disableAutocorrection(true)
        .toolbar(content: {
//                if self.connectionsStore.outOfSyncCount > 0 {
//                    ToolbarItem(placement: .navigationBarLeading) {
//                        if syncing {
//                            ProgressView()
//                        } else if (!self.accountStore.deviceSettings.autoSync) {
//                            Button {
//                                self.sync(dryRun: true)
//                            } label: {
//                                Text("Sync (\(self.connectionsStore.outOfSyncCount))")
//                            }
//                        }
//                    }
//                }
            ToolbarItem(placement: .navigationBarTrailing) {
                // TODO
                Image(systemName: "qrcode.viewfinder")
                    .toolbarButtonStyle()
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                // TODO
                Image(systemName: "qrcode")
                    .toolbarButtonStyle()
            }
        })
        .onChange(of: self.nameFilter.debouncedText) { text in
            self.connectionsStore.load(nameFilter: text, permissionGroup: self.selectedGroup)
        }
        .onChange(of: self.selectedGroup) { group in
            self.connectionsStore.load(nameFilter: self.nameFilter.text, permissionGroup: group)
        }
        .refreshable {
            self.connectionsStore.load(nameFilter: self.nameFilter.debouncedText, permissionGroup: self.selectedGroup)
            self.connectionsStore.loadOutOfSync { _ in
                if self.accountStore.deviceSettings.autoSync {
                    self.sync(dryRun: false)
                }
            }
        }
    }
    
    var deleteAlert: Alert {
        Alert(title: Text("Delete confirmation"), message: Text("Are you sure you want to remove this connection?"), primaryButton: .destructive(Text("Delete")) {
            for index in self.toBeDeleted! {
                let connectionid = self.connectionsStore.connections[index].id
                self.connectionStore.delete(connectionId: connectionid) { (result: Result<Bool, Error>) in
                    switch result {
                    case.success(_):
                        self.connectionsStore.load()
                        self.connectionsStore.loadOutOfSync(callback: { _ in })
                        self.connectionsStore.loadRejectedUsers()
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
        })
    }
    
    var contactUpdatesSheet: some View {
        ScrollView {
            VStack {
                if (self.contactsToSyncCount > 0 && !self.accountStore.deviceSettings.autoSync) {
                    Text("\(self.contactUpdates.count) contact(s) to sync")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding([.top], 10)
                } else {
                    Text("\(self.contactUpdates.count) contact(s) synced!")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding([.top], 10)
                }
                
                Divider().padding([.top, .bottom], 10)
                
                ForEach(self.contactUpdates, id: \.self.connection.id) { (update: ContactStore.ContactSyncInfo) in
                    if (update.changedFields().count > 0) {
                        VStack(alignment: .leading) {
                            HStack {
                                ProfileImage(imageUrl: update.connection.profileImage, height: 50, width: 50)
                                Text("\(update.connection.firstName) \(update.connection.lastName)")
                                Spacer()
                                if (!update.isUpdate) {
                                    Text("New!")
                                        .italic()
                                        .fontWeight(.semibold)
                                }
                            }
                            .padding([.bottom], 10)
                            
                            ForEach(update.changedFields(), id: \.self.field) { (fieldUpdate: ContactStore.ContactSyncFieldInfo) in
                                if fieldUpdate.oldValue != fieldUpdate.newValue {
                                    VStack(alignment: .leading) {
                                        Text(fieldUpdate.field).personalInfoLabel()
                                        Text(fieldUpdate.newValue!).personalInfo()
                                    }
                                }
                            }
                        }
                        .frame(
                            minWidth: 0,
                            maxWidth: .infinity,
                            minHeight: 0,
                            maxHeight: .infinity,
                            alignment: .topLeading
                        )
                        .padding([.leading, .trailing], 10)
                        
                        Divider().padding([.top, .bottom], 10)
                    }
                }
            }
            .padding()
            
            Spacer()
            
            if (self.contactsToSyncCount > 0 && !self.accountStore.deviceSettings.autoSync) {
                Button(action: {
                    self.sync(dryRun: false)
                }, label: {
                    Text("Sync")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 50)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .foregroundColor(ColorConstants.secondary)
                        )
                })
            }
        }
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
    
    func delete(at offsets: IndexSet) {
        self.toBeDeleted = offsets
        self.showDeleteAlert = true
    }
    
    func sync(dryRun: Bool) {
        self.syncing = true
        self.showContactUpdates = false
        self.contactUpdates = []
        
        self.connectionsStore.loadOutOfSync { (result: Result<ConnectionResponse, Error>) in
            switch result {
            case .success(let response):
                if response.count > 0 {
                    self.contactStore.syncContacts(connections: response.users, dryRun: dryRun) { syncInfo in
                        self.contactUpdates.append(contentsOf: syncInfo.updatedContacts)
                        
                        if (!dryRun) {
                            UIApplication.shared.applicationIconBadgeNumber = 0
                            self.contactsToSyncCount = 0
                            self.connectionsStore.loadOutOfSync { _ in }
                        } else {
                            self.contactsToSyncCount = self.contactUpdates.count
                        }
                        
                        self.showContactUpdates = true
                        self.syncing = false
                    }
                }
            case .failure(let error):
                print("Something bad happened", error.localizedDescription)
                self.contactUpdates = []
                self.syncing = false
            }
        }
    }
}

struct ConnectionList_Previews: PreviewProvider {
    static let modelData = ModelData()
    static let usersStore = UsersStore(users: modelData.connectionResponse.users)
    static let connectionsStore = ConnectionsStore(connections: modelData.connectionResponse.users,
                                                   requests: modelData.requests,
                                                   blockedUsers: modelData.connectionResponse.users)
    static let connectionStore = ConnectionStore()
    static let contactStore = ContactStore()
    static let accountStore = AccountStore(user: modelData.user)
    
    static var previews: some View {
        ConnectionList()
            .environmentObject(connectionsStore)
            .environmentObject(usersStore)
            .environmentObject(contactStore)
            .environmentObject(accountStore)
            .environmentObject(connectionStore)
    }
}
