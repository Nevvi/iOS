//
//  GroupConnectionRow.swift
//  Nevvi
//
//  Created by Tyler Standal on 1/22/24.
//

import SwiftUI
import NukeUI

struct GroupConnectionRow: View {
    var connection: Connection
    
    @ObservedObject var connectionGroupStore: ConnectionGroupStore
    @EnvironmentObject var connectionGroupsStore: ConnectionGroupsStore
    
    @State private var toBeDeleted: Connection?
    @State private var showDeleteAlert: Bool = false
    
    var body: some View {
        ZStack(alignment: .trailing) {
            ConnectionRow(connection: self.connection)
            
            Spacer()
            
            Image(systemName: "trash")
                .toolbarButtonStyle()
                .onTapGesture {
                    self.showDeleteAlert = true
                }
                .padding()
        }
        .alert(isPresented: self.$showDeleteAlert) {
            deleteAlert
        }
    }
    
    var deleteAlert: Alert {
        Alert(title: Text("Delete confirmation"), message: Text("Are you sure you want to remove this connection from the group?"), primaryButton: .destructive(Text("Delete")) {

            self.connectionGroupStore.removeFromGroup(userId: self.connection.id) { (result: Result<Bool, Error>) in
                switch result {
                case.success(_):
                    self.connectionGroupsStore.load()
                    self.connectionGroupStore.loadConnections(groupId: self.connectionGroupStore.id, name: "")
                case .failure(let error):
                    print("Something bad happened", error)
                }
            }
            self.showDeleteAlert = false
        }, secondaryButton: .cancel() {
            self.showDeleteAlert = false
        }
        )
    }
}

struct GroupConnectionRow_Previews: PreviewProvider {
    static let modelData = ModelData()
    
    static var connections = modelData.connectionResponse.users
    
    static let connectionGroupStore = ConnectionGroupStore(group: modelData.groups[0], connections: modelData.connectionResponse.users)
    
    static var previews: some View {
        Group {
            GroupConnectionRow(connection: connections[0], connectionGroupStore: connectionGroupStore)
            GroupConnectionRow(connection: connections[1], connectionGroupStore: connectionGroupStore)
        }
        .previewLayout(.fixed(width: 300, height: 70))
    }
}
