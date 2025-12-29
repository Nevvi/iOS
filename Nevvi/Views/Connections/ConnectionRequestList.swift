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
    @EnvironmentObject var suggestionsStore: ConnectionSuggestionStore

    var notConnectedUsers: [Connection] {
        self.suggestionsStore.users.filter {
            $0.connected != nil && !$0.connected! &&
            $0.requested != nil && !$0.requested!
        }
    }

    @State private var showToast: Bool = false
        
    var body: some View {
        VStack {
            connectionRequestsView
        }
        .navigationTitle("New Connections")
        .navigationBarTitleDisplayMode(.inline)
        .toast(isPresenting: $showToast){
            AlertToast(displayMode: .banner(.slide), type: .complete(Color.green), title: "Request sent!")
        }
    }
    
    var connectionRequestsView: some View {
        VStack {
            if self.connectionsStore.requestCount == 0 {
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
                }.padding(.top)
            }
        }
        .refreshable {
            self.connectionsStore.loadRequests()
            self.suggestionsStore.loadSuggestions()
        }
    }
    
    var noRequestsView: some View {
        VStack(alignment: .center, spacing: 16) {
            Image("UpdateProfile")
            
            Text("No connection requests")
                .defaultStyle(size: 24, opacity: 1.0)
            
            Text("When someone wants to connect with you, their request will appear here!")
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
            .redacted(when: self.connectionsStore.deletingRequest || self.connectionsStore.loadingRequests || self.connectionsStore.confirmingRequest, redactionType: .customPlaceholder)
        }
    }
}

struct ConnectionRequestList_Previews: PreviewProvider {
    static let modelData = ModelData()
    static let suggestionsStore = ConnectionSuggestionStore(users: [])
    static let connectionsStore = ConnectionsStore(connections: modelData.connectionResponse.users,
                                                   requests: [],
                                                   blockedUsers: modelData.connectionResponse.users)
    
    static var previews: some View {
        ConnectionRequestList()
            .environmentObject(connectionsStore)
            .environmentObject(suggestionsStore)
    }
}
