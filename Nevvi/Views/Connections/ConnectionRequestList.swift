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
    
    @State private var showError: Bool = false
    @State private var error: Error? = nil
        
    var body: some View {
        NavigationView {
            List {
                if self.connectionsStore.requests.count == 0 && self.connectionsStore.loadingRequests == false {
                    HStack {
                        Spacer()
                        VStack {
                            Image(systemName: "person.2.slash")
                                .resizable()
                                .frame(width: 120, height: 100)
                            Text("No requests found")
                        }
                        Spacer()
                    }
                    .padding([.top], 50)
                } else {
                    ForEach(self.connectionsStore.requests, id: \.requestingUserId) { request in
                        ActionableConnectionRequestRow(approvalCallback: { (id: String, group: String) in
                            self.connectionsStore.confirmRequest(otherUserId: id, permissionGroup: group) { (result: Result<Bool, Error>) in
                                switch result {
                                case .success(_):
                                    self.connectionsStore.loadRequests()
                                case .failure(let error):
                                    self.error = error
                                    self.showError = true
                                }
                            }
                        }, request: request)
                    }
                    .onDelete(perform: self.delete)
                    .redacted(when: self.connectionsStore.loadingRequests, redactionType: .customPlaceholder)
                }
            }
            .scrollContentBackground(.hidden)
            .navigationTitle("Requests")
            .navigationBarTitleDisplayMode(.inline)
            .alert(isPresented: self.$showDeleteAlert) {
                Alert(title: Text("Delete request?"), message: Text("Are you sure you want to delete this request? This person will no longer show up in your searches."), primaryButton: .destructive(Text("Delete")) {
                    for index in self.toBeDeleted! {
                        let otherUserId = self.connectionsStore.requests[index].requestingUserId
                        self.connectionsStore.denyRequest(otherUserId: otherUserId) { (result: Result<Bool, Error>) in
                            switch result {
                            case.success(_):
                                self.connectionsStore.loadRequests()
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
            .alert(isPresented: self.$showError) {
                Alert(title: Text("Something went wrong"), message: Text(self.error!.localizedDescription))
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
    static let connectionsStore = ConnectionsStore(connections: modelData.connectionResponse.users, requests: [])
    
    static var previews: some View {
        ConnectionRequestList(connectionsStore: connectionsStore)
    }
}
