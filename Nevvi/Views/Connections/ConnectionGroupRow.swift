//
//  ConnectionRow.swift
//  Nevvi
//
//  Created by Tyler Cobb on 12/29/22.
//

import SwiftUI

struct ConnectionGroupRow: View {
    var connectionGroupStore: ConnectionGroupStore
    var connectionStore: ConnectionStore
    
    var connectionGroup: ConnectionGroup
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top) {
                NavigationLink {
                    NavigationLazyView(
                        ConnectionGroupDetail(connectionGroupStore: self.connectionGroupStore, connectionStore: self.connectionStore)
                            .onAppear {
                                self.connectionGroupStore.load(group: self.connectionGroup)
                            }
                    )
                } label: {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(self.connectionGroup.name)")
                            .defaultStyle(size: 20, opacity: 1.0)
                        
                        Text("\(connectionGroup.connections.count) \(connectionGroup.connections.count == 1 ? "member" : "members")")
                            .defaultStyle(size: 14, opacity: 0.4)
                    }
                    .padding(0)
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                }
                
                Spacer()
                
                Menu {
                    Button(role: .destructive) {
                        
                    } label: {
                        Label("Delete Group", systemImage: "trash")
                    }
                    
                    Button {
                        
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
            .padding(.horizontal, 0)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity, alignment: .top)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .background(.white)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(ColorConstants.badgeBackground, lineWidth: 1)
        )
    }
}

struct ConnectionGroup_Previews: PreviewProvider {
    static var modelData = ModelData()

    static let connectionGroupStore = ConnectionGroupStore(group: modelData.groups[0], connections: modelData.connectionResponse.users)
    static let connectionStore = ConnectionStore()
    
    static var previews: some View {
        Group {
            ConnectionGroupRow(
                connectionGroupStore: self.connectionGroupStore,
                connectionStore: self.connectionStore, 
                connectionGroup: modelData.groups[0]
            )
        }
        .previewLayout(.fixed(width: 300, height: 70))
    }
}
