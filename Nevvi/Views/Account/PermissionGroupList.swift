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
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack {
                    ForEach(self.accountStore.permissionGroups, id: \.name) { group in
                        ActionablePermissionGroupRow(group: group)
                            .padding([.leading, .trailing, .bottom])
                    }
                    .redacted(when: self.accountStore.loading, redactionType: .customPlaceholder)
                }
            }
            
            Spacer()
            
            HStack {
                Button {
                    self.showNewGroup = true
                } label: {
                    Text("New Permission Group".uppercased())
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 24)
                                .foregroundColor(ColorConstants.primary)
                        )
                }
            }
            .padding([.horizontal], 16)
            .padding([.vertical], 20)
        }
        .sheet(isPresented: self.$showNewGroup) {
            newPermissionGroupSheet
        }
        .padding([.top])
    }
    
    var newPermissionGroupSheet: some View {
        DynamicSheet(
            VStack {
                TextField("Group Name", text: self.$newGroupName)
                    .padding()
                    .overlay(RoundedRectangle(cornerRadius: 16.0).strokeBorder(Color.secondary, style: StrokeStyle(lineWidth: 1.0)))
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                    .padding([.top])
                
                Divider().padding(.vertical)
                
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
                        self.accountStore.permissionGroups.append(
                            PermissionGroup(name: self.newGroupName, fields: self.newGroupFields)
                        )
                        self.accountStore.save { (result: Result<User, Error>) in
                            switch result {
                            case .success(_):
                                self.showNewGroup = false
                            case .failure(let error):
                                print("Something went wrong", error)
                            }
                        }
                    } label: {
                        Text("Save".uppercased())
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 24)
                                    .foregroundColor(ColorConstants.primary)
                            )
                            .opacity(self.newGroupName.isEmpty || self.accountStore.saving ? 0.5 : 1.0)
                    }
                    .disabled(self.newGroupName.isEmpty || self.accountStore.saving)
                }
            }
            .padding()
        )
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
