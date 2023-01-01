//
//  ConnectionRequestList.swift
//  Nevvi
//
//  Created by Tyler Cobb on 12/31/22.
//

import SwiftUI

struct ConnectionRequestList: View {
    @ObservedObject var accountStore: AccountStore
    @ObservedObject var connectionsStore: ConnectionsStore
    
    var body: some View {
        NavigationView {
            List {
                ForEach(self.connectionsStore.requests, id: \.requestingUserId) { request in
                    ActionableConnectionRequestRow(accountStore: self.accountStore, approvalCallback: { (id: String, group: String) in
                        print(id, group)
                    }, request: request)
                }
            }.navigationTitle("Requests")
        }
    }
}

struct ConnectionRequestList_Previews: PreviewProvider {
    static let modelData = ModelData()
    static let connectionsStore = ConnectionsStore(connections: modelData.connectionResponse.users, requests: modelData.requests)
    static let accountStore = AccountStore(user: modelData.user)
    
    static var previews: some View {
        ConnectionRequestList(accountStore: accountStore, connectionsStore: connectionsStore).environmentObject(modelData)
    }
}
