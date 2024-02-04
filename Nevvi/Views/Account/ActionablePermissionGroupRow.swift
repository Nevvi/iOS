//
//  EdittablePermissionGroupRow.swift
//  Nevvi
//
//  Created by Tyler Standal on 1/26/24.
//

import SwiftUI
import WrappingHStack

struct ActionablePermissionGroupRow: View {
    @EnvironmentObject var accountStore: AccountStore
    @EnvironmentObject var connectionStore: ConnectionStore
    
    @State var group: PermissionGroup = PermissionGroup(name: "", fields: [])
    
    @State var editting: Bool = false
    
    var selectedFields: [String] {
        self.group.fields    }
    
    var unSelectedFields: [String] {
        Constants.AllFields.filter { field in
            !self.group.fields.contains(field)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
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
                    } else {
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
            
            Divider()
            
            VStack(alignment: .leading) {
                Text("Permission to view")
                    .fontWeight(.ultraLight)
                    .padding([.top, .bottom], 6)
                permissionGroupFields
                
                if self.editting {
                    Divider()
                    
                    Text("Restricted")
                        .fontWeight(.ultraLight)
                        .padding([.top, .bottom], 6)
                    
                    optionalGroupFields
                }
                
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
            } else {
                ForEach(self.selectedFields, id: \.self) { field in
                    permissionGroupField(field: field)
                }
            }
        }
    }
    
    var optionalGroupFields: some View {
        WrappingHStack(alignment: .leading) {
            ForEach(self.unSelectedFields.sorted(), id: \.self) { field in
                permissionGroupField(field: field)
            }
        }
    }
    
    func permissionGroupField(field: String) -> some View {
        var textColor = ColorConstants.badgeText
        var backgroundColor = ColorConstants.badgeBackground
        var opacity = 1.0
        var canSelect = self.editting
        
        if field.uppercased() == "EVERYTHING" {
            textColor = ColorConstants.badgeTextSuccess
            backgroundColor = ColorConstants.badgeSuccess
            canSelect = false
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

struct ActionablePermissionGroupRow_Previews: PreviewProvider {
    static let modelData = ModelData()
    static let accountStore = AccountStore(user: modelData.user)
    static let connectionStore = ConnectionStore(connection: modelData.connection)
    
    static var previews: some View {
        ActionablePermissionGroupRow(group: PermissionGroup(name: "Family", fields: ["email", "phoneNumber", "birthday"]))
            .environmentObject(accountStore)
            .environmentObject(connectionStore)
//        PermissionGroupRow(group: PermissionGroup(name: "Family", fields: []))
//        PermissionGroupRow(group: PermissionGroup(name: "All", fields: []))
    }
}
