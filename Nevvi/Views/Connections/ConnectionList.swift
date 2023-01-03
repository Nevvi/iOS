//
//  ConnectionList.swift
//  Nevvi
//
//  Created by Tyler Cobb on 12/29/22.
//

import SwiftUI

struct ConnectionList: View {
    @ObservedObject var usersStore: UsersStore
    @ObservedObject var connectionsStore: ConnectionsStore
    @ObservedObject var connectionStore: ConnectionStore
    
    @State private var toBeDeleted: IndexSet?
    @State private var showDeleteAlert: Bool = false
    @StateObject var nameFilter = DebouncedText()
    
    var body: some View {
        NavigationView {
            if self.connectionsStore.connectionCount == 0 {
                Text("No connections :(")
                    .navigationTitle("Connections")
            } else {
                List {
                    ForEach(self.connectionsStore.connections) { connection in
                        NavigationLink {
                            NavigationLazyView(
                                ConnectionDetail(connectionStore: self.connectionStore)
                                    .onAppear {
                                        self.connectionStore.load(connectionId: connection.id)
                                    }
                            )
                        } label: {
                            ConnectionRow(connection: connection)
                        }
                    }
                    .onDelete(perform: self.delete)
                }
                .navigationTitle("Connections")
                .navigationBarTitleDisplayMode(.automatic)
                .navigationBarItems(trailing: NavigationLink {
                    ConnectionSearch(usersStore: self.usersStore)
                        .navigationBarTitleDisplayMode(.inline)
                        .padding([.top], -100)
                } label: {
                    Image(systemName: "plus").foregroundColor(.blue)
                })
                .alert(isPresented: self.$showDeleteAlert) {
                    Alert(title: Text("Delete confirmation"), message: Text("Are you sure you want to remove this connection?"), primaryButton: .destructive(Text("Delete")) {
                        for index in self.toBeDeleted! {
                            let connectionid = self.connectionsStore.connections[index].id
                            self.connectionStore.delete(connectionId: connectionid) { (result: Result<Bool, Error>) in
                                switch result {
                                case.success(_):
                                    self.connectionsStore.load()
                                case .failure(let error):
                                    print(error)
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
                .searchable(text: self.$nameFilter.text)
                .onChange(of: self.nameFilter.debouncedText) { text in
                    self.connectionsStore.load(nameFilter: text)
                }
            }
        }
    }
    
    func delete(at offsets: IndexSet) {
        self.toBeDeleted = offsets
        self.showDeleteAlert = true
    }
}

struct ConnectionList_Previews: PreviewProvider {
    static let modelData = ModelData()
    static let usersStore = UsersStore(users: modelData.connectionResponse.users)
    static let connectionsStore = ConnectionsStore(connections: modelData.connectionResponse.users, requests: modelData.requests)
    static let connectionStore = ConnectionStore()
    
    static var previews: some View {
        ConnectionList(usersStore: usersStore, connectionsStore: connectionsStore, connectionStore: connectionStore)
    }
}
