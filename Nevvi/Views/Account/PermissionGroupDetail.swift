//
//  PermissionGroupDetail.swift
//  Nevvi
//
//  Created by Tyler Cobb on 1/15/23.
//

import SwiftUI

struct PermissionGroupDetail: View {
    
    @State var group: PermissionGroup = PermissionGroup(name: "", fields: [])
    
    @State var groupName: String = ""
    @State var enableFirstName: Bool = true
    @State var enableLastName: Bool = true
    @State var enableEmail: Bool = false
    @State var enablePhone: Bool = false
    @State var enableAddress: Bool = false
    @State var enableMailingAddress: Bool = false
    @State var enableBirthday: Bool = false
    
    var callback: (PermissionGroup) -> Void
    
    var body: some View {
        VStack {
            if self.group.name == "" {
                TextField("Group Name", text: self.$groupName)
                    .padding()
                    .overlay(RoundedRectangle(cornerRadius: 10.0).strokeBorder(Color.secondary, style: StrokeStyle(lineWidth: 1.0)))
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                    .padding([.bottom], 30)
            } else {
                Text(self.group.name)
                    .font(.title2)
                    .padding([.bottom], 30)
            }
            
            Toggle("First Name", isOn: self.$enableFirstName)
                .disabled(true)
                .tint(ColorConstants.secondary)
            
            Toggle("Last Name", isOn: self.$enableLastName)
                .disabled(true)
                .tint(ColorConstants.secondary)
            
            Toggle("Email", isOn: self.$enableEmail)
                .onChange(of: self.enableEmail) { newValue in
                    handleToggle(newValue: newValue, field: "email")
                }
                .tint(ColorConstants.secondary)
            
            Toggle("Phone Number", isOn: self.$enablePhone)
                .onChange(of: self.enablePhone) { newValue in
                    handleToggle(newValue: newValue, field: "phoneNumber")
                }
                .tint(ColorConstants.secondary)
            
            Toggle("Address", isOn: self.$enableAddress)
                .onChange(of: self.enableAddress) { newValue in
                    handleToggle(newValue: newValue, field: "address")
                }
                .tint(ColorConstants.secondary)
            
            Toggle("Mailing Address", isOn: self.$enableMailingAddress)
                .onChange(of: self.enableMailingAddress) { newValue in
                    handleToggle(newValue: newValue, field: "mailingAddress")
                }
                .tint(ColorConstants.secondary)
            
            Toggle("Birthday", isOn: self.$enableBirthday)
                .onChange(of: self.enableBirthday) { newValue in
                    handleToggle(newValue: newValue, field: "birthday")
                }
                .tint(ColorConstants.secondary)
            
            Spacer()
            
            saveButton
        }
        .onAppear {
            self.groupName = self.group.name
            self.enableEmail = self.group.fields.contains("email")
            self.enablePhone = self.group.fields.contains("phoneNumber")
            self.enableAddress = self.group.fields.contains("address")
            self.enableMailingAddress = self.group.fields.contains("mailingAddress")
            self.enableBirthday = self.group.fields.contains("birthday")
        }
        .padding()
    }
    
    var saveButton: some View {
        Button(action: {
            group.name = self.groupName
            callback(group)
        }, label: {
            Text("Save")
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal, 50)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .foregroundColor(ColorConstants.secondary)
                )
                .opacity(self.groupName == "" ? 0.5 : 1.0)
        })
        .shadow(radius: 10)
        .disabled(self.groupName == "")
    }
    
    func handleToggle(newValue: Bool, field: String) {
        if newValue && !group.fields.contains(field) {
            group.fields.append(field)
        } else if (!newValue) {
            group.fields.removeAll { (fieldName: String) in
                fieldName == field
            }
        }
    }
}

struct PermissionGroupDetail_Previews: PreviewProvider {
    static let modelData = ModelData()
    static var previews: some View {
        PermissionGroupDetail(group: modelData.user.permissionGroups[1]) { (group: PermissionGroup) in
            print("Saving group", group)
        }
    }
}
