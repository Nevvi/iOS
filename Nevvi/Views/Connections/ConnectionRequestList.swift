//
//  ConnectionRequestList.swift
//  Nevvi
//
//  Created by Tyler Cobb on 12/31/22.
//

import SwiftUI

struct ConnectionRequestList: View {
    @EnvironmentObject var connectionsStore: ConnectionsStore
    
    @State private var toBeDeleted: IndexSet?
    @State private var showDeleteAlert: Bool = false
        
    var body: some View {
        NavigationView {
            List {
                if self.connectionsStore.requestCount == 0 {
                    noRequestsView
                } else {
                    requestsView
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(self.connectionsStore.requestCount == 0 ? .hidden : .visible)
            .navigationTitle("Requests")
            .navigationBarTitleDisplayMode(.large)
            .refreshable {
                self.connectionsStore.loadRequests()
            }
        }
        .alert(isPresented: self.$showDeleteAlert) {
            deleteAlert
        }
    }
    
    var noRequestsView: some View {
        HStack {
            Spacer()
            if self.connectionsStore.loadingRequests {
                ProgressView()
            } else {
                NoDataFound(imageName: "person.2.slash", height: 100, width: 120, text: "No requests found")
            }
            Spacer()
        }
        .padding([.top], 100)
        .listRowSeparator(.hidden)
    }
    
    var requestsView: some View {
        ForEach(self.connectionsStore.requests, id: \.requestingUserId) { request in
            ActionableConnectionRequestRow(approvalCallback: { (id: String, group: String) in
                self.connectionsStore.confirmRequest(otherUserId: id, permissionGroup: group) { (result: Result<Bool, Error>) in
                    switch result {
                    case .success(_):
                        self.connectionsStore.loadRequests()
                    case .failure(let error):
                        print("Something bad happened", error)
                    }
                }
            }, request: request)
        }
        .onDelete(perform: self.delete)
        .redacted(when: self.connectionsStore.loadingRequests, redactionType: .customPlaceholder)
    }
    
    var deleteAlert: Alert {
        Alert(title: Text("Delete request?"), message: Text("Are you sure you want to delete this request? This person will no longer show up in your normal searches."), primaryButton: .destructive(Text("Delete")) {
            for index in self.toBeDeleted! {
                let otherUserId = self.connectionsStore.requests[index].requestingUserId
                self.connectionsStore.denyRequest(otherUserId: otherUserId) { (result: Result<Bool, Error>) in
                    switch result {
                    case.success(_):
                        self.connectionsStore.loadRequests()
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
    
    func delete(at offsets: IndexSet) {
        self.toBeDeleted = offsets
        self.showDeleteAlert = true
        print(offsets)
    }
}

struct ConnectionRequestList_Previews: PreviewProvider {
    static let modelData = ModelData()
    static let connectionsStore = ConnectionsStore(connections: modelData.connectionResponse.users,
                                                   requests: [],
                                                   blockedUsers: modelData.connectionResponse.users)
    
    static var previews: some View {
        ConnectionRequestList()
            .environmentObject(connectionsStore)
            .environmentObject(AccountStore(user: modelData.user))
    }
}
