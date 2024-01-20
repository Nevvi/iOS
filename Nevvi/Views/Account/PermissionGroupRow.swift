//
//  PermissionGroupRow.swift
//  Nevvi
//
//  Created by Tyler Standal on 1/15/24.
//

import SwiftUI
import WrappingHStack

struct PermissionGroupRow: View {
    @EnvironmentObject var connectionStore: ConnectionStore
    @State var group: PermissionGroup = PermissionGroup(name: "", fields: [])
    
    @State var selectable: Bool = true
    
    var isSelected: Bool {
        return self.connectionStore.permissionGroup == self.group.name
    }

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                if self.selectable {
                    HStack {
                        if self.isSelected {
                            Image(systemName: "checkmark")
                                .frame(width: 28, height: 28)
                                .foregroundColor(.white)
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                                .background(ColorConstants.primary)
                                .cornerRadius(8)
                                .fontWeight(.light)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8).stroke(ColorConstants.primary, lineWidth: 1)
                                )
                        } else {
                            RoundedRectangle(cornerRadius: 8).stroke(.gray, lineWidth: 1)
                                .frame(width: 28, height: 28)
                                .foregroundColor(ColorConstants.badgeText)
                                .background(.white)
                                .onTapGesture {
                                    self.connectionStore.permissionGroup = self.group.name
                                    self.connectionStore.update { (result: Result<Connection, Error>) in
                                        switch result {
                                        case .success(let connection):
                                            print("Updated connection with \(connection.id)")
                                        case .failure(let error):
                                            print("Something bad happened", error)
                                        }
                                    }
                                }
                        }
                
                        Text(group.name)
                            .textCase(.uppercase)
                            .fontWeight(.bold)
                            .padding([.top, .bottom], 6)
                            .disabled(self.group.name == self.connectionStore.permissionGroup)
                    }
                } else {
                    Text(group.name)
                    .textCase(.uppercase)
                    .fontWeight(.bold)
                    .padding([.top, .bottom], 6)
                }
            }
            Divider()
            VStack(alignment: .leading) {
                Text("Permission to view")
                    .fontWeight(.ultraLight)
                    .padding([.top, .bottom], 6)
                permissionGroupFields
            }
        }
        .padding()
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(ColorConstants.badgeBackground, lineWidth: 1)
        )
    }
    
    var permissionGroupFields: some View {
        WrappingHStack(alignment: .leading) {
            if group.name.uppercased() == "ALL" {
                permissionGroupField(field: "Everything")
            } else if(group.fields.isEmpty) {
                permissionGroupField(field: "Nothing")
            } else {
                ForEach(group.fields, id: \.self) { field in
                    permissionGroupField(field: field)
                }
            }
        }
    }
    
    func permissionGroupField(field: String) -> some View {
        var textColor = ColorConstants.badgeText
        var backgroundColor = ColorConstants.badgeBackground
        if field.uppercased() == "EVERYTHING" {
            textColor = ColorConstants.badgeTextSuccess
            backgroundColor = ColorConstants.badgeSuccess
        } else if (field.uppercased() == "NOTHING") {
            textColor = ColorConstants.badgeTextWarning
            backgroundColor = ColorConstants.badgeWarning
        }
        
        return Text(field.humanReadable())
            .padding([.leading, .trailing], 14)
            .padding([.top, .bottom], 8)
            .foregroundColor(textColor)
            .background(backgroundColor)
            .cornerRadius(30)
            .fontWeight(.light)
    }
}

struct PermissionGroupRow_Previews: PreviewProvider {
    static let modelData = ModelData()
    static let connectionStore = ConnectionStore(connection: modelData.connection)
    
    static var previews: some View {
        PermissionGroupRow(group: PermissionGroup(name: "Family", fields: ["firstName", "lastName", "email", "phoneNumber", "address", "birthday"]))
            .environmentObject(connectionStore)
//        PermissionGroupRow(group: PermissionGroup(name: "Family", fields: []))
//        PermissionGroupRow(group: PermissionGroup(name: "All", fields: []))
    }
}
