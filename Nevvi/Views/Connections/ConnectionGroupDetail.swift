//
//  ConnectionGroupDetail.swift
//  Nevvi
//
//  Created by Tyler Cobb on 1/9/23.
//

import AlertToast
import SwiftUI

struct ConnectionGroupDetail: View {
    @EnvironmentObject var accountStore: AccountStore
    @EnvironmentObject var connectionGroupStore: ConnectionGroupStore
        
    @State var showToast: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top, spacing: 8) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("\(self.connectionGroupStore.name)")
                        .defaultStyle(size: 20, opacity: 1.0)
                    
                    Text("Members (\(self.connectionGroupStore.connectionCount))")
                        .defaultStyle(size: 16, opacity: 0.6)
                }
                
                Spacer()
                
                Menu {
                    Button {
                        self.connectionGroupStore.exportGroupData { (result: Result<Bool, Error>) in
                            switch result {
                            case .success(_):
                                self.showToast = true
                            case .failure(let error):
                                print("Failed to export", error)
                            }
                        }
                    } label: {
                        Label("Export to CSV", systemImage: "envelope")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .frame(width: 24, height: 24)
                        .rotationEffect(.degrees(-90))
                        .foregroundColor(.gray)
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .overlay(
              Rectangle()
                .inset(by: 0.5)
                .stroke(Color(red: 0, green: 0.07, blue: 0.17).opacity(0.08), lineWidth: 1)
            )
            
            VStack(alignment: .trailing, spacing: 0) {
                if self.connectionGroupStore.loading || self.connectionGroupStore.connectionCount == 0 {
                    noConnectionsView
                } else {
                    connectionsView
                }
            }
        }
        .navigationTitle(self.connectionGroupStore.name)
        .navigationBarTitleDisplayMode(.inline)
        .toast(isPresenting: $showToast){
            AlertToast(displayMode: .banner(.slide), type: .complete(Color.green), title: "Export sent to \(self.accountStore.email)")
        }
    }
    
    var noConnectionsView: some View {
        HStack {
            Spacer()
            if self.connectionGroupStore.loadingConnections {
                ProgressView()
            } else {
                NoDataFound(imageName: "person.2.slash", height: 100, width: 120)
            }
            Spacer()
        }
    }
    
    var connectionsView: some View {
        ScrollView(.vertical) {
            VStack(alignment: .trailing, spacing: 0) {
                ForEach(self.connectionGroupStore.connections) { connection in
                    GroupConnectionRow(connection: connection, connectionGroupStore: self.connectionGroupStore)
                }
                .redacted(when: self.connectionGroupStore.loadingConnections || self.connectionGroupStore.deleting, redactionType: .customPlaceholder)
            }
            .frame(maxWidth: .infinity, alignment: .topTrailing)
        }
    }
}

struct ConnectionGroupDetail_Previews: PreviewProvider {
    static let modelData = ModelData()
    static let accountStore = AccountStore(user: modelData.user)
    static let connectionGroupStore = ConnectionGroupStore(group: modelData.groups[0], connections: modelData.connectionResponse.users)
    
    static var previews: some View {
        ConnectionGroupDetail()
            .environmentObject(accountStore)
            .environmentObject(connectionGroupStore)
    }
}
