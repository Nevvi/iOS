//
//  ConnectionRequestList.swift
//  Nevvi
//
//  Created by Tyler Cobb on 12/31/22.
//

import AlertToast
import SwiftUI

struct ConnectionRequestList: View {
    @EnvironmentObject var connectionsStore: ConnectionsStore
    @EnvironmentObject var contactStore: ContactStore
    @EnvironmentObject var usersStore: UsersStore

    var notConnectedUsers: [Connection] {
        self.usersStore.users.filter {
            $0.connected != nil && !$0.connected! &&
            $0.requested != nil && !$0.requested!
        }
    }
    
    @State private var toBeDeleted: IndexSet?
    @State private var showDeleteAlert: Bool = false
    @State private var showToast: Bool = false
        
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    if self.connectionsStore.requestCount == 0 {
                        noRequestsView
                    } else {
                        requestsView
                    }
                                    
                    if self.notConnectedUsers.count > 0 {
                        suggestionsView
                            .padding([.top], 8)
                    }
                }
            }
            .navigationTitle("New Connections")
            .navigationBarTitleDisplayMode(.large)
            .refreshable {
                self.connectionsStore.loadRequests()
            }
            .toolbar(content: {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: UserSearch()) {
                        Image(systemName: "plus.magnifyingglass")
                            .toolbarButtonStyle()
                            .foregroundColor(.black)
                    }
                }
            })
        }
        .alert(isPresented: self.$showDeleteAlert) {
            deleteAlert
        }
        .toast(isPresenting: $showToast){
            AlertToast(displayMode: .banner(.slide), type: .complete(Color.green), title: "Request sent!")
        }
        .onAppear {
//            self.usersStore.users = []
//            self.usersStore.userCount = 0
//            self.contactStore.loadContactPhoneNumbers { (result: Result<[String], Error>) in
//                switch result {
//                case .success(let phoneNumbers):
//                    self.usersStore.searchByPhoneNumbers(phoneNumbers: phoneNumbers)
//                case .failure(_):
//                    // TODO - show some sort of alert
//                    print("Something bad happened")
//                }
//            }
        }
    }
    
    var noRequestsView: some View {
        HStack(alignment: .center) {
            VStack(alignment: .center, spacing: 16) {
                if self.notConnectedUsers.count == 0 {
                    Spacer()
                    Spacer()
                }
                    
                Image("UpdateProfile")
                
                Text("No connection requests")
                    .defaultStyle(size: 24, opacity: 1.0)
                
                Text("When someone wants to connect we'll let you know!")
                    .defaultStyle(size: 16, opacity: 0.7)
                    .multilineTextAlignment(.center)
            }
            .padding()
        }.padding([.horizontal])
    }
    
    var requestsView: some View {
        VStack(alignment: .leading, spacing: 0) {
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
    }
    
    var suggestionsView: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Found new members")
                        .defaultStyle(size: 20, opacity: 1.0)
                    
                    Text("based on your local contact list")
                        .defaultStyle(size: 14, opacity: 0.5)
                }
                .padding(0)
                .frame(width: 257, alignment: .topLeading)
                
                Spacer()
                
                Text("\(self.notConnectedUsers.count) \(self.notConnectedUsers.count == 1 ? "person" : "people")")
                    .defaultStyle(size: 14, opacity: 0.7)
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 4)
            
            ForEach(self.notConnectedUsers) { user in
                NewConnectionRequestRow(requestCallback: {
                    self.showToast = true
                    self.usersStore.removeUser(user: user)
                }, user: user)
            }
            .redacted(when: self.usersStore.loading, redactionType: .customPlaceholder)
        }
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
    static let usersStore = UsersStore(users: modelData.connectionResponse.users)
    static let connectionsStore = ConnectionsStore(connections: modelData.connectionResponse.users,
                                                   requests: modelData.requests,
                                                   blockedUsers: modelData.connectionResponse.users)
    
    static var previews: some View {
        ConnectionRequestList()
            .environmentObject(connectionsStore)
            .environmentObject(AccountStore(user: modelData.user))
            .environmentObject(usersStore)
            .environmentObject(ContactStore())
    }
}
