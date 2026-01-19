//
//  PermissionGroupList.swift
//  Nevvi
//
//  Created by Tyler Cobb on 1/15/23.
//

import SwiftUI
import WrappingHStack

struct PermissionGroupList: View {
    @EnvironmentObject var accountStore: AccountStore
        
    @State var showNewGroup: Bool = false
    @State var selectedGroup: PermissionGroup? = nil
    
    @State var newGroupName: String = ""
    @State var newGroupFields: [String] = []
    
    var body: some View {
        VStack {
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(self.accountStore.permissionGroups, id: \.name) { group in
                        ActionablePermissionGroupRow(group: group)
                            .padding([.leading, .trailing, .bottom])
                    }
                    .redacted(when: self.accountStore.loading || self.accountStore.saving, redactionType: .customPlaceholder)
                }
            }
            
            Spacer()
        }
        .sheet(isPresented: self.$showNewGroup) {
            newPermissionGroupSheet
        }
        .refreshable {
            self.accountStore.load()
        }
        .toolbar(content: {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Image(systemName: "plus")
                    .toolbarButtonStyle()
                    .onTapGesture {
                        self.showNewGroup = true
                    }
            }
        })
    }
    
    var newPermissionGroupSheet: some View {
        VStack(spacing: 0) {
            // Header
            VStack(alignment: .leading, spacing: 24) {
                Text("Create New Group")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 8)
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Group Name")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    TextField("Enter group name", text: self.$newGroupName)
                        .textFieldStyle(.plain)
                        .font(.body)
                        .textInputAutocapitalization(.words)
                        .disableAutocorrection(false)
                        .disabled(self.accountStore.saving)
                        .opacity(self.accountStore.saving ? 0.6 : 1.0)
                }
            }

            Divider()
                .padding(.vertical, 16)
            
            VStack(alignment: .leading) {
                Text("Permission to view")
                    .fontWeight(.ultraLight)
                    .padding([.top, .bottom], 6)
                
                WrappingHStack(alignment: .leading) {
                    ForEach(Constants.AllFields.sorted(), id: \.self) { field in
                        permissionGroupField(field: field)
                    }
                }
            }.padding(.bottom, 32)
            
            Spacer()
            
            HStack {
                Button {
                    self.showNewGroup = false
                    self.accountStore.addPermissionGroup(newGroup: PermissionGroup(name: self.newGroupName, fields: self.newGroupFields)
                    ) { (result: Result<User, Error>) in
                        switch result {
                        case .success(_):
                            self.newGroupName = ""
                            self.newGroupFields = []
                        case .failure(let error):
                            print("Something went wrong", error)
                        }
                    }
                } label: {
                    Text("Save".uppercased())
                        .asPrimaryButton()
                        .opacity(self.newGroupName.isEmpty || self.accountStore.saving ? 0.5 : 1.0)
                }
                .disabled(self.newGroupName.isEmpty || self.accountStore.saving)
            }
        }
        .padding()
    }
    
    func permissionGroupField(field: String) -> some View {
        var textColor = ColorConstants.badgeText
        var backgroundColor = ColorConstants.badgeBackground
        
        if (self.newGroupFields.contains(field)) {
            textColor = .white
            backgroundColor = ColorConstants.primary
        }
        
        return Text(field.humanReadable())
            .padding([.leading, .trailing], 14)
            .padding([.top, .bottom], 8)
            .foregroundColor(textColor)
            .background(backgroundColor)
            .cornerRadius(30)
            .fontWeight(.light)
            .onTapGesture {
                if self.newGroupFields.contains(field) {
                    self.newGroupFields.removeAll { groupField in
                        groupField == field
                    }
                } else {
                    self.newGroupFields.append(field)
                }
            }
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
