//
//  ConnectionSearchResults.swift
//  Nevvi
//
//  Created by Tyler Standal on 12/28/25.
//

import SwiftUI

struct ConnectionSearchResults: View {
    @EnvironmentObject var connectionStore: ConnectionStore
    @EnvironmentObject var connectionsStore: ConnectionsStore
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Your Connections")
                            .font(.headline)
                            .fontWeight(.semibold)
                        Text("People you're already connected with")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Text("\(connectionsStore.connectionCount)")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 16)
                
                VStack(spacing: 0) {
                    ForEach(connectionsStore.connections) { connection in
                        NavigationLink {
                            NavigationLazyView(
                                ConnectionDetail()
                                    .onAppear {
                                        loadConnection(connectionId: connection.id)
                                    }
                            )
                        } label: {
                            ConnectionRow(connection: connection)
                        }
                    }
                }
            }
        }
    }
        
    func loadConnection(connectionId: String) {
        self.connectionStore.load(connectionId: connectionId) { (result: Result<Connection, Error>) in
            switch result {
            case .success(_):
                print("Got connection \(connectionId)")
            case .failure(let error):
                print("Something bad happened", error)
            }
        }
    }
}

    struct ConnectionSearchResults_Previews: PreviewProvider {
        static let modelData = ModelData()
        static let connectionsStore = ConnectionsStore(connections: modelData.connectionResponse.users,
                                                       requests: modelData.requests,
                                                       blockedUsers: modelData.connectionResponse.users)
        static let connectionStore = ConnectionStore()
        
        static var previews: some View {
            ConnectionSearchResults()
                .environmentObject(connectionsStore)
                .environmentObject(connectionStore)
        }
    }
