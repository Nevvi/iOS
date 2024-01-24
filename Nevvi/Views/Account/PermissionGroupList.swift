//
//  PermissionGroupList.swift
//  Nevvi
//
//  Created by Tyler Cobb on 1/15/23.
//

import SwiftUI

struct PermissionGroupList: View {
    @EnvironmentObject var accountStore: AccountStore
    
    @State var showNewGroup: Bool = false
    @State var showGroupEdit: Bool = false
    @State var selectedGroup: PermissionGroup? = nil
    
    var body: some View {
        ScrollView {
            VStack {
                ForEach(self.accountStore.permissionGroups, id: \.name) { group in
                    PermissionGroupRow(group: group, selectable: false)
                        .padding([.leading, .trailing, .bottom])
                }
                .redacted(when: self.accountStore.loading, redactionType: .customPlaceholder)
            }
        }
        .sheet(isPresented: self.$showNewGroup) {
            newPermissionGroupSheet
        }
        .toolbar(content: {
            Image(systemName: "plus").foregroundColor(.blue)
                .onTapGesture {
                    self.showNewGroup = true
                }
        })
        .padding([.top])
    }
    
    var editPermissionGroupSheet: some View {
        PermissionGroupDetail(group: self.selectedGroup!, callback: { (group: PermissionGroup) in
            self.accountStore.permissionGroups = self.accountStore.permissionGroups.map { existingGroup in
                return existingGroup.name == group.name ? group : existingGroup
            }
            self.accountStore.save { (result: Result<User, Error>) in
                switch result {
                case .success(_):
                    self.showGroupEdit = false
                case .failure(let error):
                    print("Something went wrong", error)
                }
            }
        })
        .padding()
        .presentationDetents([.fraction(0.66)])
    }
    
    var newPermissionGroupSheet: some View {
        PermissionGroupDetail(callback: { (group: PermissionGroup) in
            self.accountStore.permissionGroups.append(group)
            self.accountStore.save { (result: Result<User, Error>) in
                switch result {
                case .success(_):
                    self.showNewGroup = false
                case .failure(let error):
                    print("Something went wrong", error)
                }
            }
        })
        .padding()
        .presentationDetents([.fraction(0.66)])
    }
}

struct PermissionGroupList_Previews: PreviewProvider {
    static let modelData = ModelData()
    static let accountStore = AccountStore(user: modelData.user)
    
    static var previews: some View {
        PermissionGroupList()
            .environmentObject(accountStore)
    }
}
