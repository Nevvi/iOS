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
    
    @ObservedObject var connectionStore: ConnectionStore
    
    @State private var syncing: Bool = false
    @State private var showSyncConfirmation: Bool = false
    @State private var toBeDeleted: IndexSet?
    @State private var showDeleteAlert: Bool = false
    
    @State private var contactsToSyncCount: Int = 0
    @State private var contactUpdates: [ContactStore.ContactSyncInfo] = []
    @State private var showContactUpdates: Bool = false
    
    @StateObject var nameFilter = DebouncedText()
        
    var body: some View {
        NavigationView {
            List {
                if self.connectionsStore.connectionCount == 0 {
                    noConnectionsView
                } else {
                    connectionsView
                }
            }
            .listStyle(.plain)
            .background(Color.black.ignoresSafeArea())
            .scrollContentBackground(self.connectionsStore.connectionCount == 0 ? .hidden : .visible)
            .navigationTitle("Connections")
            .navigationBarTitleDisplayMode(.large)
            .toolbar(content: {
                if self.connectionsStore.outOfSyncCount > 0 {
                    ToolbarItem(placement: .navigationBarLeading) {
                        if syncing {
                            ProgressView()
                        } else if (!self.accountStore.deviceSettings.autoSync) {
                            Button {
                                self.sync(dryRun: true)
                            } label: {
                                Text("Sync (\(self.connectionsStore.outOfSyncCount))")
                            }
                        }
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: UserSearch()) {
                        Image(systemName: "plus")
                    }
                    .padding([.trailing], 5)
                }
            })
            .searchable(text: self.$nameFilter.text)
            .disableAutocorrection(true)
            .onChange(of: self.nameFilter.debouncedText) { text in
                self.connectionsStore.load(nameFilter: text)
            }
            .refreshable {
                self.connectionsStore.load(nameFilter: self.nameFilter.debouncedText)
                self.connectionsStore.loadOutOfSync { _ in
                    if self.accountStore.deviceSettings.autoSync {
                        self.sync(dryRun: false)
                    }
                }
            }
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
    
    var noConnectionsView: some View {
        HStack {
            Spacer()
            if self.connectionsStore.loading {
                ProgressView()
            } else {
                NoDataFound(imageName: "person.2.slash", height: 100, width: 120, text: "No connections")
            }
            Spacer()
        }
        .padding([.top], 100)
        .listRowSeparator(.hidden)
    }
    
    var connectionsView: some View {
        ForEach(self.connectionsStore.connections) { connection in
            NavigationLink {
                NavigationLazyView(
                    ConnectionDetail(connectionStore: self.connectionStore)
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
    static let connectionsStore = ConnectionsStore(connections: [],
                                                   requests: modelData.requests,
                                                   blockedUsers: modelData.connectionResponse.users)
    static let connectionStore = ConnectionStore()
    static let contactStore = ContactStore()
    static let accountStore = AccountStore(user: modelData.user)
    
    static var previews: some View {
        ConnectionList(connectionStore: connectionStore)
            .environmentObject(connectionsStore)
            .environmentObject(usersStore)
            .environmentObject(contactStore)
            .environmentObject(accountStore)
    }
}
