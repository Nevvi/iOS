//
//  PermissionGroupPicker.swift
//  Nevvi
//
//  Created by Tyler Standal on 1/15/24.
//

import SwiftUI
import WrappingHStack

struct PermissionGroupPicker: View {
    @EnvironmentObject var accountStore: AccountStore
    @Binding var selectedGroup: String
    
    var body: some View {
        WrappingHStack(alignment: .leading) {
            ForEach(self.accountStore.permissionGroups, id: \.name) { group in
                permissionGroupOption(groupName: group.name)
            }
        }.padding()
    }
    
    func permissionGroupOption(groupName: String) -> some View {
        let backgroundColor = groupName == self.selectedGroup ?
            ColorConstants.primary : ColorConstants.badgeBackground
        
        let borderColor = groupName == self.selectedGroup ?
            ColorConstants.primary : .gray
        
        let textColor = groupName == self.selectedGroup ?
            .white : ColorConstants.badgeText
        
        return HStack {
            if groupName == self.selectedGroup {
                Image(systemName: "checkmark.circle")
            }
            
            Text(groupName.uppercased())
        }
        .fontWeight(.medium)
        .padding([.leading, .trailing], 16)
        .padding([.top, .bottom], 14)
        .foregroundColor(textColor)
        .background(backgroundColor)
        .cornerRadius(30)
        .fontWeight(.light)
        .overlay(
            RoundedRectangle(cornerRadius: 30).stroke(borderColor, lineWidth: 1)
        )
        .onTapGesture {
            self.selectedGroup = groupName
        }
    }
}

#if DEBUG
struct PermissionGroupPickerBinding_Previews : View {
    @State var selectedPermissionGroup: String = "Everything"

     var body: some View {
          PermissionGroupPicker(selectedGroup: $selectedPermissionGroup)
     }
}

struct PermissionGroupPicker_Previews: PreviewProvider {
    static let modelData = ModelData()
    static let accountStore = AccountStore(user: modelData.user)
    
    static var previews: some View {
        PermissionGroupPickerBinding_Previews()
            .environmentObject(accountStore)
    }
}
#endif
