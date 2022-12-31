//
//  ConnectionRequestList.swift
//  Nevvi
//
//  Created by Tyler Cobb on 12/31/22.
//

import SwiftUI

struct ConnectionRequestList: View {
    @ObservedObject var accountStore: AccountStore
    
    @State var requests: [ConnectionRequest]
    
    var body: some View {
        NavigationView {
            List {
                ForEach(self.requests, id: \.requestingUserId) { request in
                    ActionableConnectionRequestRow(myUser: self.accountStore.user!, approvalCallback: { (id: String, group: String) in
                        print(id, group)
                    }, request: request)
                }
            }.navigationTitle("Requests")
        }
    }
}

struct ConnectionRequestList_Previews: PreviewProvider {
    static let modelData = ModelData()
    static let accountStore = AccountStore(user: modelData.user)
    
    static var previews: some View {
        ConnectionRequestList(accountStore: accountStore, requests: modelData.requests).environmentObject(modelData)
    }
}
