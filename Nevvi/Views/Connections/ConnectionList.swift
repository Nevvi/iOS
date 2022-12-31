//
//  ConnectionList.swift
//  Nevvi
//
//  Created by Tyler Cobb on 12/29/22.
//

import SwiftUI

struct ConnectionList: View {
    @State var connections: [Connection]
    @ObservedObject var connectionStore: ConnectionStore
    
    @State private var toBeDeleted: IndexSet?
    @State private var showDeleteAlert: Bool = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(connections) { connection in
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
                    .alert(isPresented: self.$showDeleteAlert) {
                        Alert(title: Text("Delete confirmation"), message: Text("Are you sure you want to remove \(connection.firstName) as a connection?"), primaryButton: .destructive(Text("Delete")) {
                                for index in self.toBeDeleted! {
                                    print("Connection will be deleted here")
                                }
                                self.toBeDeleted = nil
                            }, secondaryButton: .cancel() {
                                self.toBeDeleted = nil
                            }
                        )
                    }
                }
                .onDelete(perform: self.delete)
            }.navigationTitle("Connections")
        }
    }
    
    func delete(at offsets: IndexSet) {
        self.toBeDeleted = offsets
        self.showDeleteAlert = true
    }
}

struct ConnectionList_Previews: PreviewProvider {
    static let modelData = ModelData()
    static var previews: some View {
        ConnectionList(connections: modelData.connectionResponse.users, connectionStore: ConnectionStore()).environmentObject(modelData)
    }
}
