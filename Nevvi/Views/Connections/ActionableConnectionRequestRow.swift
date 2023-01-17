//
//  ActionableConnectionRequestRow.swift
//  Nevvi
//
//  Created by Tyler Cobb on 12/31/22.
//

import SwiftUI

struct ActionableConnectionRequestRow: View {
    @EnvironmentObject var accountStore: AccountStore
    
    var approvalCallback: (String, String) -> Void
    
    @State var request: ConnectionRequest
    @State var showSheet: Bool = false
    @State var selectedPermissionGroup: String = "ALL"
    
    var body: some View {
        HStack {
            ProfileImage(imageUrl: request.requesterImage, height: 50, width: 50)
                .padding([.trailing], 10)
            
            Text(self.request.requestText)
            
            Spacer()
            
            approveButton
        }
        .padding(5)
        .sheet(isPresented: self.$showSheet) {
            approveSheet
        }
    }
    
    var approveButton: some View {
        Button {
            self.showSheet = true
        } label: {
            Text("Approve")
        }
    }
    
    var approveSheet: some View {
        ZStack {
            VStack {
                ProfileImage(imageUrl: request.requesterImage, height: 50, width: 50)
                    .padding([.top], 30)
                
                Text("Which permission group should this new connection belong to?")
                    .font(.title2)
                    .padding([.top, .leading, .trailing])
                                    
                Picker("Which permission group should this new connection belong to?", selection: self.$selectedPermissionGroup) {
                    ForEach(self.accountStore.permissionGroups, id: \.name) {
                        Text($0.name.uppercased())
                    }
                }
                .pickerStyle(.wheel)
                .padding([.top], -25)
                
                Button(action: {
                    self.approvalCallback(self.request.requestingUserId, self.selectedPermissionGroup)
                    self.showSheet = false
                }, label: {
                    Text("Confirm")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 50)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .foregroundColor(Color(UIColor(hexString: "#49C5B6")))
                        )
                })
                .padding([.bottom])
            }
        }.presentationDetents([.medium])
    }
}

struct ActionableConnectionRequestRow_Previews: PreviewProvider {
    static let modelData = ModelData()
    static let accountStore = AccountStore(user: modelData.user)
    static var previews: some View {
        ActionableConnectionRequestRow(approvalCallback: { (id: String, group: String) in
            print(id, group)
        }, request: modelData.requests[0])
            .environmentObject(accountStore)
    }
}
