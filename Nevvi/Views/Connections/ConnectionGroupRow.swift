//
//  ConnectionRow.swift
//  Nevvi
//
//  Created by Tyler Cobb on 12/29/22.
//

import SwiftUI

struct ConnectionGroupRow: View {
    @EnvironmentObject var accountStore: AccountStore
    @EnvironmentObject var connectionStore: ConnectionStore
    @EnvironmentObject var connectionGroupsStore: ConnectionGroupsStore
    
    var connectionGroup: ConnectionGroup
    
    @State var selectable: Bool = false
    @State var actionable: Bool = false
    
    var isSelected: Bool {
        return self.connectionGroup.connections.contains(self.connectionStore.id)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center) {
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(self.connectionGroup.name)")
                        .defaultStyle(size: 20, opacity: 1.0)
                    
                    Text("\(connectionGroup.connections.count) \(connectionGroup.connections.count == 1 ? "member" : "members")")
                        .defaultStyle(size: 14, opacity: 0.4)
                }
                .padding(0)
                .frame(maxWidth: .infinity, alignment: .topLeading)
                
                if self.actionable {
                    Spacer()
                    
                    Menu {
                        Button(role: .destructive) {
                            self.connectionGroupsStore.delete(groupId: self.connectionGroup.id) { (result: Result<Bool, Error>) in
                                switch result {
                                    case .success(_):
                                    self.connectionGroupsStore.load()
                                    case .failure(let error):
                                    print("Failed to delete group", error)
                                }
                            }
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
                } else if self.selectable {
                    if self.isSelected {
                        Image(systemName: "minus")
                            .toolbarButtonStyle()
                            .foregroundColor(.red)
                            .opacity(self.connectionGroupsStore.loading ? 0.5 : 1.0)
                            .onTapGesture {
                                self.connectionGroupsStore.removeFromGroup(groupId: self.connectionGroup.id, userId: self.connectionStore.id) { (result: Result<Bool, Error>) in
                                        switch result {
                                            case .success(_):
                                            self.connectionGroupsStore.load()
                                            case .failure(let error):
                                            print("Failed to remove from group", error)
                                        }
                                    }
                            }
                    } else {
                        Image(systemName: "plus")
                            .toolbarButtonStyle()
                            .opacity(self.connectionGroupsStore.loading ? 0.5 : 1.0)
                            .onTapGesture {
                                self.connectionGroupsStore.addToGroup(groupId: self.connectionGroup.id, userId: self.connectionStore.id) { (result: Result<Bool, Error>) in
                                        switch result {
                                            case .success(_):
                                            self.connectionGroupsStore.load()
                                            case .failure(let error):
                                            print("Failed to add to group", error)
                                        }
                                    }
                            }
                    }
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
    static let modelData = ModelData()
    
    static let accountStore = AccountStore(user: modelData.user)
    static let connectionGroupsStore = ConnectionGroupsStore(groups: modelData.groups)
    static let connectionStore = ConnectionStore()
    
    static var previews: some View {
        Group {
            ConnectionGroupRow(
                connectionGroup: modelData.groups[0],
                selectable: true,
                actionable: false
            )
        }
        .previewLayout(.fixed(width: 300, height: 70))
        .environmentObject(accountStore)
        .environmentObject(connectionGroupsStore)
        .environmentObject(connectionStore)
    }
}
