//
//  BlockedUserLists.swift
//  Nevvi
//
//  Created by Tyler Cobb on 1/4/23.
//

import SwiftUI

struct BlockedUserList: View {
    @EnvironmentObject var connectionsStore: ConnectionsStore
    @EnvironmentObject var usersStore: UsersStore
    
    @StateObject var nameFilter = DebouncedText()
    
    @State private var showInfo: Bool = false
        
    var body: some View {
        NavigationView {
            List {
                if self.connectionsStore.blockedUserCount == 0 && self.connectionsStore.loadingBlockerUsers == false {
                    NoDataFound(imageName: "person.2.slash", height: 120, width: 120)
                } else {
                    ForEach(self.connectionsStore.blockedUsers) { user in
                        NewConnectionRequestRow(requestCallback: { (id: String, group: String) in
                            self.usersStore.requestConnection(userId: id, groupName: group) { (result: Result<Bool, Error>) in
                                switch result {
                                case .success(_):
                                    self.connectionsStore.loadRejectedUsers()
                                case .failure(let error):
                                    print("Something went wrong", error)
                                }
                            }
                        }, user: user)
                    }
                    .redacted(when: self.connectionsStore.loadingBlockerUsers, redactionType: .customPlaceholder)
                }
            }
            .scrollContentBackground(.hidden)
            .padding([.top], -20)
            .sheet(isPresented: self.$showInfo) {
                Text("Blocked users do not show up in your normal search results and you do not show up in theirs. The only way to unblock a user is to re-connect with them.")
                    .foregroundColor(.secondary)
                    .fontWeight(.light)
                    .font(.system(size: 16))
                    .padding()
                    .presentationDetents([.height(150)])
            }
        }
        .toolbar(content: {
            Image(systemName: "info.circle")
                .padding([.trailing])
                .onTapGesture {
                    self.showInfo.toggle()
                }
        })
        .navigationTitle("Blocked Users")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct BlockedUserList_Previews: PreviewProvider {
    static let modelData = ModelData()
    static let accountStore = AccountStore(user: modelData.user)
    static let usersStore = UsersStore(users: modelData.connectionResponse.users)
    static let connectionsStore = ConnectionsStore(connections: modelData.connectionResponse.users,
                                                   requests: modelData.requests,
                                                   blockedUsers: modelData.connectionResponse.users)
    
    static var previews: some View {
        BlockedUserList()
            .environmentObject(connectionsStore)
            .environmentObject(accountStore)
            .environmentObject(usersStore)
    }
}
