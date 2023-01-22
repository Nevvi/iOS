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
            .scrollContentBackground(.hidden)
            .navigationTitle("Connections")
            .navigationBarTitleDisplayMode(.large)
            .toolbar(content: {
                if self.connectionsStore.outOfSyncCount > 0 {
                    ToolbarItem(placement: .navigationBarLeading) {
                        if syncing {
                            ProgressView()
                        } else if (!self.accountStore.deviceSettings.autoSync) {
                            Button {
                                self.showSyncConfirmation = true
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
        }
        .alert(isPresented: self.$showDeleteAlert) {
            deleteAlert
        }
        .alert(isPresented: self.$showSyncConfirmation) {
            syncConfirmation
        }
        .onAppear {
            if self.accountStore.deviceSettings.autoSync {
                self.sync()
            }
        }
    }
    
    var noConnectionsView: some View {
        HStack {
            Spacer()
            if self.connectionsStore.loading {
                ProgressView()
            } else {
                NoDataFound(imageName: "person.2.slash", height: 100, width: 120)
            }
            Spacer()
        }
        .padding([.top], 100)
    }
    
    var connectionsView: some View {
        ForEach(self.connectionsStore.connections) { connection in
            NavigationLink {
                NavigationLazyView(
                    RefreshableView(onRefresh: {
                        loadConnection(connectionId: connection.id)
                    }, view: ConnectionDetail(connectionStore: self.connectionStore)
                        .onAppear {
                            loadConnection(connectionId: connection.id)
                        }
                    )
                )
            } label: {
                ConnectionRow(connection: connection)
            }
            .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
        }
        .onDelete(perform: self.delete)
        .redacted(when: self.connectionsStore.loading, redactionType: .customPlaceholder)
    }
    
    var deleteAlert: Alert {
        Alert(title: Text("Delete confirmation"), message: Text("Are you sure you want to remove this connection?"), primaryButton: .destructive(Text("Delete")) {
            for index in self.toBeDeleted! {
                let connectionid = self.connectionsStore.connections[index].id
                self.connectionStore.delete(connectionId: connectionid) { (result: Result<Bool, Error>) in
                    switch result {
                    case.success(_):
                        self.connectionsStore.load()
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
    
    var syncConfirmation: Alert {
        Alert(title: Text("Sync Confirmation"),
              // TODO include some more info about who and what is being synced here
              message: Text("Would you like to sync \(self.connectionsStore.outOfSyncCount) updated contact(s) to you device?"),
              primaryButton: .default(Text("Yes"), action: {
                  self.sync()
                  self.showSyncConfirmation = false
              }),
              secondaryButton: .cancel(Text("No"))
        )
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
    
    func sync() {
        // TODO - bail out after X attempts
        self.syncing = true
        self.connectionsStore.loadOutOfSync { (result: Result<ConnectionResponse, Error>) in
            switch result {
            case .success(let response):
                // Stop the recursion once we get to 0
                if response.count != 0 {
                    self.contactStore.syncContacts(connections: response.users) {
                        // Either grab the next batch of connections to sync or reset the count to 0
                        self.sync()
                    }
                } else {
                    self.syncing = false
                    UIApplication.shared.applicationIconBadgeNumber = 0
                }
            case .failure(let error):
                print("Something bad happened", error.localizedDescription)
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
        ConnectionList(connectionStore: connectionStore)
            .environmentObject(connectionsStore)
            .environmentObject(usersStore)
            .environmentObject(contactStore)
            .environmentObject(accountStore)
    }
}
