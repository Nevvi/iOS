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
    @EnvironmentObject var suggestionsStore: ConnectionSuggestionStore

    var notConnectedUsers: [Connection] {
        self.suggestionsStore.users.filter {
            $0.connected != nil && !$0.connected! &&
            $0.requested != nil && !$0.requested!
        }
    }

    @State private var showToast: Bool = false
        
    var body: some View {
        NavigationView {
            VStack {
                if self.connectionsStore.requestCount == 0 && self.notConnectedUsers.count == 0 {
                    GeometryReader { geometry in
                        ScrollView(.vertical) {
                            noRequestsView
                                .frame(width: geometry.size.width)
                                .frame(minHeight: geometry.size.height)
                        }
                    }
                } else {
                    ScrollView {
                        requestsView
                        
                        if self.notConnectedUsers.count > 0 {
                            suggestionsView
                        }
                    }.padding(.top)
                }
            }
            .refreshable {
                self.connectionsStore.loadRequests()
            }
            .toolbar(content: {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: UserSearch()) {
                        Image(systemName: "plus.magnifyingglass")
                            .toolbarButtonStyle()
                    }
                    
                    // TODO
//                    Image(systemName: "qrcode.viewfinder").toolbarButtonStyle()
                }
            })
            .navigationTitle("New Connections")
            .navigationBarTitleDisplayMode(.inline)
        }
        .toast(isPresenting: $showToast){
            AlertToast(displayMode: .banner(.slide), type: .complete(Color.green), title: "Request sent!")
        }
        .onAppear {
            self.suggestionsStore.users = []
            self.suggestionsStore.userCount = 0
            if self.contactStore.hasAccess() {
                self.contactStore.loadContactPhoneNumbers { (result: Result<[String], Error>) in
                    switch result {
                    case .success(let phoneNumbers):
                        self.suggestionsStore.searchByPhoneNumbers(phoneNumbers: phoneNumbers)
                    case .failure(_):
                        // TODO - show some sort of alert
                        print("Something bad happened")
                    }
                }
            }
        }
    }
    
    var noRequestsView: some View {
        VStack(alignment: .center, spacing: 16) {
            Image("UpdateProfile")
            
            Text("No connection requests")
                .defaultStyle(size: 24, opacity: 1.0)
            
            Text("When someone wants to connect we'll let you know!")
                .defaultStyle(size: 16, opacity: 0.7)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal)
        .padding(.bottom, 64)
    }
    
    var requestsView: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(self.connectionsStore.requests, id: \.requestingUserId) { request in
                ActionableConnectionRequestRow(request: request)
            }
            .redacted(when: self.connectionsStore.deletingRequest || self.connectionsStore.loadingRequests, redactionType: .customPlaceholder)
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
                    self.suggestionsStore.removeUser(user: user)
                }, user: user)
            }
            .redacted(when: self.suggestionsStore.loading || self.connectionsStore.loadingRequests, redactionType: .customPlaceholder)
        }
    }
}

struct ConnectionRequestList_Previews: PreviewProvider {
    static let modelData = ModelData()
    static let suggestionsStore = ConnectionSuggestionStore(users: modelData.connectionResponse.users)
    static let connectionsStore = ConnectionsStore(connections: modelData.connectionResponse.users,
                                                   requests: modelData.requests,
                                                   blockedUsers: modelData.connectionResponse.users)
    
    static var previews: some View {
        ConnectionRequestList()
            .environmentObject(connectionsStore)
            .environmentObject(AccountStore(user: modelData.user))
            .environmentObject(suggestionsStore)
            .environmentObject(ContactStore())
    }
}
