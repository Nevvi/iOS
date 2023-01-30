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
        NavigationView {
            List {
                ForEach(self.accountStore.permissionGroups, id: \.name) { group in
                    HStack {
                        Text(group.name.uppercased())
                        if group.name.uppercased() != "ALL" {
                            Spacer()
                            Text("(\(group.fields.count) fields)")
                        }
                    }
                    .padding([.top, .bottom])
                    .onTapGesture {
                        // Can't edit the ALL group
                        if group.name.uppercased() != "ALL" {
                            self.selectedGroup = group
                            self.showGroupEdit = true
                        }
                    }
                }
                .redacted(when: self.accountStore.loading, redactionType: .customPlaceholder)
            }
            .padding([.top], -20)
            .sheet(isPresented: self.$showGroupEdit) {
                editPermissionGroupSheet
            }
            .sheet(isPresented: self.$showNewGroup) {
                newPermissionGroupSheet
            }
            
            Text("\(self.selectedGroup?.name ?? "")")
                .hidden()
        }
        .toolbar(content: {
            Image(systemName: "plus").foregroundColor(.blue)
                .onTapGesture {
                    self.showNewGroup = true
                }
        })
        .navigationTitle("Permission Groups")
        .navigationBarTitleDisplayMode(.inline)
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
