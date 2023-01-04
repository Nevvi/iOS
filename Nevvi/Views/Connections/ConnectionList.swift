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
    
    @State private var showError: Bool = false
    @State private var error: Error? = nil
        
    var body: some View {
        NavigationView {
            List {
                if self.connectionsStore.connectionCount == 0 && self.connectionsStore.loading == false {
                    HStack {
                        Spacer()
                        VStack {
                            Image(systemName: "person.2.slash")
                                .resizable()
                                .frame(width: 120, height: 100)
                            Text("No connections found")
                        }
                        Spacer()
                    }
                    .padding([.top], 50)
                } else {
                    ForEach(self.connectionsStore.connections) { connection in
                        NavigationLink {
                            NavigationLazyView(
                                RefreshableView(onRefresh: {
                                    self.connectionStore.load(connectionId: connection.id) { (result: Result<Connection, Error>) in
                                        switch result {
                                        case .success(_):
                                            print("Got connection \(connection.id)")
                                        case .failure(let error):
                                            self.error = error
                                            self.showError = true
                                        }
                                    }
                                }, view: ConnectionDetail(connectionStore: self.connectionStore)
                                    .onAppear {
                                        self.connectionStore.load(connectionId: connection.id) { (result: Result<Connection, Error>) in
                                            switch result {
                                            case .success(_):
                                                print("Got connection \(connection.id)")
                                            case .failure(let error):
                                                self.error = error
                                                self.showError = true
                                            }
                                        }
                                    }
                                               )
                            )
                        } label: {
                            ConnectionRow(connection: connection)
                        }
                    }
                    .onDelete(perform: self.delete)
                    .redacted(when: self.connectionsStore.loading, redactionType: .customPlaceholder)
                }
            }
            .scrollContentBackground(.hidden)
            .navigationTitle("Connections")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: {
                NavigationLink {
                    ConnectionSearch(usersStore: self.usersStore)
                        .navigationBarTitleDisplayMode(.inline)
                        .padding([.top], -100)
                } label: {
                    Image(systemName: "plus").foregroundColor(.blue)
                }
            })
            .alert(isPresented: self.$showError) {
                Alert(title: Text("Something went wrong"), message: Text(self.error!.localizedDescription))
            }
            .alert(isPresented: self.$showDeleteAlert) {
                Alert(title: Text("Delete confirmation"), message: Text("Are you sure you want to remove this connection?"), primaryButton: .destructive(Text("Delete")) {
                    for index in self.toBeDeleted! {
                        let connectionid = self.connectionsStore.connections[index].id
                        self.connectionStore.delete(connectionId: connectionid) { (result: Result<Bool, Error>) in
                            switch result {
                            case.success(_):
                                self.connectionsStore.load()
                            case .failure(let error):
                                self.error = error
                                self.showError = true
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
            .disableAutocorrection(true)
            .onChange(of: self.nameFilter.debouncedText) { text in
                self.connectionsStore.load(nameFilter: text)
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
