//
//  ConnectionRow.swift
//  Nevvi
//
//  Created by Tyler Cobb on 12/29/22.
//

import SwiftUI

struct ConnectionGroupMembershipRow: View {
    @EnvironmentObject var connectionGroupsStore: ConnectionGroupsStore
    @ObservedObject var connectionStore: ConnectionStore
    
    @State var loading: Bool = false
    
    @State var isMember: Bool
    var group: ConnectionGroup
    
    var body: some View {
        HStack {
            Toggle(group.name, isOn: self.$isMember)
                .onChange(of: self.isMember) { newValue in
                    self.loading = true
                    self.handleChange(toggled: newValue)
                }
                .disabled(self.loading)
                .tint(ColorConstants.secondary)
        }
    }
    
    func handleChange(toggled: Bool) {
        if toggled {
            self.connectionGroupsStore.addToGroup(groupId: group.id, userId: self.connectionStore.id) { (result: Result<Bool, Error>) in
                    self.loading = false
                    switch result {
                        case .success(_):
                        self.connectionGroupsStore.load()
                        case .failure(let error):
                        print("Failed to add to group", error)
                    }
                }
        } else {
            self.connectionGroupsStore.removeFromGroup(groupId: group.id, userId: self.connectionStore.id) { (result: Result<Bool, Error>) in
                    self.loading = false
                    switch result {
                        case .success(_):
                        self.connectionGroupsStore.load()
                        case .failure(let error):
                        print("Failed to remove from group", error)
                    }
                }
        }
    }
}

struct ConnectionGroupMembershipRow_Previews: PreviewProvider {
    static var modelData = ModelData()
    static let connectionGroupsStore = ConnectionGroupsStore(groups: modelData.groups)
    static let connectionStore = ConnectionStore(connection: modelData.connection)
    
    static var previews: some View {
        ConnectionGroupMembershipRow(connectionStore: connectionStore, isMember: true, group: modelData.groups[0])
            .environmentObject(connectionGroupsStore)
        
    }
}
