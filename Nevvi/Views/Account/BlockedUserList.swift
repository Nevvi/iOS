//
//  BlockedUserLists.swift
//  Nevvi
//
//  Created by Tyler Cobb on 1/4/23.
//

import AlertToast
import SwiftUI

struct BlockedUserList: View {
    @EnvironmentObject var connectionsStore: ConnectionsStore
    @EnvironmentObject var usersStore: UsersStore
    
    @StateObject var nameFilter = DebouncedText()
    
    @State private var showToast: Bool = false
    @State private var showInfo: Bool = false
        
    var body: some View {
        NavigationView {
            VStack(alignment: .center, spacing: 0) {
                if self.connectionsStore.blockedUserCount == 0 {
                    noDataView
                } else {
                    blockedUsersView
                }
            }
            .refreshable {
                self.connectionsStore.loadRejectedUsers()
            }
            .sheet(isPresented: self.$showInfo) {
                Text("Blocked users do not show up in your normal search results and you do not show up in theirs. The only way to unblock a user is to re-connect with them.")
                    .foregroundColor(.secondary)
                    .fontWeight(.light)
                    .font(.system(size: 16))
                    .padding()
                    .presentationDetents([.height(150)])
            }
            .toast(isPresenting: $showToast){
                AlertToast(displayMode: .banner(.slide), type: .complete(Color.green), title: "Request sent!")
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
    
    var noDataView: some View {
        GeometryReader { geometry in
            ScrollView(.vertical) {
                HStack(alignment: .center) {
                    if self.connectionsStore.loadingBlockerUsers == true {
                        ProgressView()
                    } else {
                        VStack(alignment: .center, spacing: 24) {
                            Image("UpdateProfile")
                            
                            Text("No blocked users")
                                .defaultStyle(size: 24, opacity: 1.0)
                        }
                        .padding()
                        .padding(.bottom, 64)
                    }
                }
                .frame(width: geometry.size.width)
                .frame(minHeight: geometry.size.height)
            }
        }
    }
    
    var blockedUsersView: some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(self.connectionsStore.blockedUsers) { user in
                    NewConnectionRequestRow(requestCallback: {
                        self.showToast = true
                        self.connectionsStore.loadRejectedUsers()
                    }, user: user)
                }
                .redacted(when: self.connectionsStore.loadingBlockerUsers, redactionType: .customPlaceholder)
            }
        }
    }
}

struct BlockedUserList_Previews: PreviewProvider {
    static let modelData = ModelData()
    static let accountStore = AccountStore(user: modelData.user)
    static let usersStore = UsersStore(users: modelData.connectionResponse.users)
    static let connectionsStore = ConnectionsStore(connections: modelData.connectionResponse.users,
                                                   requests: modelData.requests,
                                                   blockedUsers: [])
    
    static var previews: some View {
        BlockedUserList()
            .environmentObject(connectionsStore)
            .environmentObject(accountStore)
            .environmentObject(usersStore)
    }
}
