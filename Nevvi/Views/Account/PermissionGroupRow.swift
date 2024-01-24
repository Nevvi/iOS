//
//  PermissionGroupRow.swift
//  Nevvi
//
//  Created by Tyler Standal on 1/15/24.
//

import SwiftUI
import WrappingHStack

struct PermissionGroupRow: View {
    @EnvironmentObject var accountStore: AccountStore
    @EnvironmentObject var connectionStore: ConnectionStore
    
    @State var group: PermissionGroup = PermissionGroup(name: "", fields: [])
    
    @State var selectable: Bool = false
    @State var actionable: Bool = true
    @State var editting: Bool = false
    
    
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
                                .opacity(self.connectionStore.saving ? 0.5 : 1.0)
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
                                    if !self.connectionStore.saving {
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
                    
                    Spacer()
                    
                    if self.group.name != "ALL" {
                        if self.editting {
                            Button(action: {
                                self.accountStore.permissionGroups = self.accountStore.permissionGroups.map { existingGroup in
                                    return existingGroup.name == group.name ? group : existingGroup
                                }
                                self.accountStore.save { (result: Result<User, Error>) in
                                    switch result {
                                    case .success(_):
                                        self.editting = false
                                    case .failure(let error):
                                        print("Something went wrong", error)
                                    }
                                }
                            }, label: {
                                Text("Save".uppercased())
                                    .fontWeight(.bold)
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding(.vertical, 6)
                                    .padding(.horizontal, 16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 24)
                                            .foregroundColor(ColorConstants.primary)
                                    )
                                    .opacity(self.accountStore.saving ? 0.5 : 1.0)
                                    .disabled(self.accountStore.saving)
                            })
                        } else if self.actionable {
                            Menu {
                                Button {
                                    self.editting = true
                                } label: {
                                    Label("Edit Group", systemImage: "pencil")
                                }
                            } label: {
                                Image(systemName: "ellipsis")
                                    .frame(width: 24, height: 24)
                                    .rotationEffect(.degrees(-90))
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
            }
            Divider()
            VStack(alignment: .leading) {
                Text("Permission to view")
                    .fontWeight(.ultraLight)
                    .padding([.top, .bottom], 6)
                permissionGroupFields
            }.animation(.easeIn, value: editting)
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
            } else if self.editting {
                ForEach(Constants.AllFields.sorted(), id: \.self) { field in
                    permissionGroupField(field: field)
                }
            } else {
                ForEach(group.fields.sorted(), id: \.self) { field in
                    permissionGroupField(field: field)
                }
            }
        }
    }
    
    func permissionGroupField(field: String) -> some View {
        var textColor = ColorConstants.badgeText
        var backgroundColor = ColorConstants.badgeBackground
        var opacity = 1.0
        var canSelect = true
        
        if field.uppercased() == "EVERYTHING" {
            textColor = ColorConstants.badgeTextSuccess
            backgroundColor = ColorConstants.badgeSuccess
            canSelect = false
        } else if (self.editting && Constants.PublicFields.contains(field)) {
            textColor = .white
            backgroundColor = ColorConstants.primary
            opacity = 0.7
            canSelect = false
        } else if (self.editting && group.fields.contains(field)) {
            textColor = .white
            backgroundColor = ColorConstants.primary
        }
        
        return Text(field.humanReadable())
            .padding([.leading, .trailing], 14)
            .padding([.top, .bottom], 8)
            .foregroundColor(textColor)
            .background(backgroundColor)
            .cornerRadius(30)
            .opacity(opacity)
            .fontWeight(.light)
            .onTapGesture {
                if canSelect {
                    if group.fields.contains(field) {
                        group.fields.removeAll { groupField in
                            groupField == field
                        }
                    } else {
                        group.fields.append(field)
                    }
                }
            }
    }
}

struct PermissionGroupRow_Previews: PreviewProvider {
    static let modelData = ModelData()
    static let accountStore = AccountStore(user: modelData.user)
    static let connectionStore = ConnectionStore(connection: modelData.connection)
    
    static var previews: some View {
        PermissionGroupRow(group: PermissionGroup(name: "Family", fields: ["email", "phoneNumber", "birthday"]))
            .environmentObject(accountStore)
            .environmentObject(connectionStore)
//        PermissionGroupRow(group: PermissionGroup(name: "Family", fields: []))
//        PermissionGroupRow(group: PermissionGroup(name: "All", fields: []))
    }
}
