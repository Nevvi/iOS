//
//  ConnectionRequestList.swift
//  Nevvi
//
//  Created by Tyler Cobb on 12/31/22.
//

import SwiftUI

struct ConnectionRequestList: View {
    @ObservedObject var connectionsStore: ConnectionsStore
    
    @State private var toBeDeleted: IndexSet?
    @State private var showDeleteAlert: Bool = false
    
    var body: some View {
        NavigationView {
            if self.connectionsStore.requests.count == 0 {
                Text("No requests :(")
                    .navigationTitle("Requests")
            } else {
                List {
                    ForEach(self.connectionsStore.requests, id: \.requestingUserId) { request in
                        ActionableConnectionRequestRow(approvalCallback: { (id: String, group: String) in
                            print(id, group)
                        }, request: request)
                    }.onDelete(perform: self.delete)
                }
                .navigationTitle("Requests")
                .alert(isPresented: self.$showDeleteAlert) {
                    Alert(title: Text("Delete request?"), message: Text("Are you sure you want to delete this request? This person will no longer show up in your searches."), primaryButton: .destructive(Text("Delete")) {
                        for index in self.toBeDeleted! {
                            let otherUserId = self.connectionsStore.requests[index].requestingUserId
                            self.connectionsStore.denyRequest(otherUserId: otherUserId) { (result: Result<Bool, Error>) in
                                switch result {
                                case.success(_):
                                    self.connectionsStore.loadRequests()
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
            }
        }
    }
    
    func delete(at offsets: IndexSet) {
        self.toBeDeleted = offsets
        self.showDeleteAlert = true
    }
}

struct ConnectionRequestList_Previews: PreviewProvider {
    static let modelData = ModelData()
    static let connectionsStore = ConnectionsStore(connections: modelData.connectionResponse.users, requests: modelData.requests)
    
    static var previews: some View {
        ConnectionRequestList(connectionsStore: connectionsStore)
    }
}
