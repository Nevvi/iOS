//
//  GroupSettings.swift
//  Nevvi
//
//  Created by Tyler Standal on 1/22/24.
//

import SwiftUI

struct GroupSettings: View {
    @State var tabSelectedValue = 0
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 12) {
                Picker("", selection: self.$tabSelectedValue) {
                    Text("Permissions".uppercased()).tag(0)
                    Text("Connections".uppercased()).tag(1)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
                
                TabView(selection: $tabSelectedValue) {
                    PermissionGroupList().tag(0)
                    
                    ConnectionGroupList().tag(1)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeIn, value: tabSelectedValue)
            }
            .navigationTitle("Groups")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct GroupSettings_Previews: PreviewProvider {
    static let modelData = ModelData()
    static let accountStore = AccountStore(user: modelData.user)
    static let connectionGroupsStore = ConnectionGroupsStore(groups: modelData.groups)
    static let connectionGroupStore = ConnectionGroupStore(group: modelData.groups[0], connections: modelData.connectionResponse.users)
    static let connectionStore = ConnectionStore()
    
    static var previews: some View {
        GroupSettings()
            .environmentObject(accountStore)
            .environmentObject(connectionGroupStore)
            .environmentObject(connectionGroupsStore)
            .environmentObject(connectionStore)
    }
}
