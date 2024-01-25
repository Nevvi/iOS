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
        HStack(alignment: .center, spacing: 12) {
            ZStack(alignment: .bottom) {
                Rectangle()
                .foregroundColor(.clear)
                .frame(width: 63, height: 63)
                .background(
                    LazyImage(url: URL(string: connection.profileImage), resizingMode: .aspectFill)
                )
                .cornerRadius(63)
                .padding([.bottom], 8)
                                
                Text(self.connection.permissionGroup ?? "Unknown")
                    .asPermissionGroupBadge(bgColor: Color(red: 0.82, green: 0.88, blue: 1))
            }
            
            HStack {
                VStack {
                    Text("\(connection.firstName) \(connection.lastName)")
                        .defaultStyle(size: 18, opacity: 1.0)
                    
                    // TODO - add phone/email if we have access
                }
                
                Spacer()
                
                Image(systemName: "trash")
                    .toolbarButtonStyle()
                    .onTapGesture {
                        self.showDeleteAlert = true
                    }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .overlay(
            Rectangle()
                .inset(by: 0.5)
                .stroke(Color(red: 0, green: 0.07, blue: 0.17).opacity(0.04), lineWidth: 1)
        )
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
