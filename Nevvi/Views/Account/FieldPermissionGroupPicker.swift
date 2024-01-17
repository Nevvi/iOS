//
//  FieldPermissionGroupPicker.swift
//  Nevvi
//
//  Created by Tyler Standal on 1/15/24.
//

import SwiftUI
import WrappingHStack

struct FieldPermissionGroupPicker: View {
    @EnvironmentObject var accountStore: AccountStore
    
    @State private var showPicker: Bool = false
    
    @State var fieldName: String
    
    @State var permissionGroupCopy: [PermissionGroup] = []

    var buttonDisabled: Bool {
        // TODO - this isn't working right
        self.accountStore.saving || self.accountStore.permissionGroups == self.permissionGroupCopy
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Permission groups with access").personalInfoLabel()
                
                matchingPermissionGroups()
            }
            
            Spacer()
            
            Button {
                self.showPicker.toggle()
            } label: {
                Image(systemName: "plus.circle")
                    .foregroundStyle(ColorConstants.primary)
            }.buttonStyle(.borderless)
        }
        .sheet(isPresented: self.$showPicker) {
            permissionGroupPicker
        }
        .onAppear {
            // TODO - kinda hacky
            self.permissionGroupCopy = self.accountStore.permissionGroups.map { $0.copy() }
        }
    }
    
    var permissionGroupPicker: some View {
        VStack(alignment: .leading) {
            Text("Permission to view")
                .font(.title)
                .padding([.top, .leading])
                .padding([.bottom], 5)
            
            Text("Your information is secure. It's only accessible to people in the following permission group(s).")
                .fontWeight(.thin)
                .font(.system(size: 16))
                .padding([.leading])
            
            List {
                ForEach(self.permissionGroupCopy, id: \.name) { group in
                    HStack {
                        PermissionGroupToggle(isOn: group.fields.contains(self.fieldName), groupName: group.name) { enabled in
                            processChange(groupName: group.name, enabled: enabled)
                        }
                        Spacer()
                    }
                    .padding([.top, .bottom], 8)
                }
            }.listStyle(.plain)
            
            Spacer()
            
            Button(action: {
                self.accountStore.permissionGroups = self.permissionGroupCopy
                self.accountStore.save { res in
                    self.showPicker = false
                }
            }, label: {
                Text("Save".uppercased())
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .foregroundColor(ColorConstants.primary)
                    )
                    .opacity(self.buttonDisabled ? 0.5 : 1.0)
            }).disabled(self.buttonDisabled)

        }
        .padding()
        .presentationDetents([.large])
    }
    
    func processChange(groupName: String, enabled: Bool) {
        self.permissionGroupCopy = self.permissionGroupCopy
            .map({ group in
                if group.name != groupName {
                    return group
                }
                
                var newGroup = group.copy()
                if enabled {
                    newGroup.addField(fieldToAdd: self.fieldName)
                } else {
                    newGroup.removeField(fieldToRemove: self.fieldName)
                }
                return newGroup
            })
    }
    
    
    func matchingPermissionGroups() -> some View {
        let matchingGroups = self.accountStore.permissionGroups.filter { group in
            group.name == "ALL" || group.fields.contains(self.fieldName)
        }
        
        return WrappingHStack(alignment: .leading) {
            ForEach(matchingGroups, id: \.name) { group in
                PermissionGroupBadge(groupName: group.name)
            }
        }
    }
}

struct FieldPermissionGroupPicker_Previews: PreviewProvider {
    static let modelData = ModelData()
    static let accountStore = AccountStore(user: modelData.user)
    
    static var previews: some View {
        FieldPermissionGroupPicker(fieldName: "email", permissionGroupCopy: accountStore.permissionGroups.map { $0.copy() })
            .environmentObject(accountStore)
    }
}
