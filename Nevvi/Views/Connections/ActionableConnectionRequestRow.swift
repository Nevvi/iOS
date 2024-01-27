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
    
    @State var loading: Bool = false
    @State var request: ConnectionRequest
    @State var showSheet: Bool = false
    @State var selectedPermissionGroup: String = "ALL"
    
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            ProfileImage(imageUrl: request.requesterImage, height: 60, width: 60)
            
            VStack(alignment: .leading) {
                Text(self.request.requestText)
                HStack {
                    approveButton
                    rejectButton
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .overlay(
            Rectangle()
                .inset(by: 0.5)
                .stroke(Color(red: 0, green: 0.07, blue: 0.17).opacity(0.04), lineWidth: 1)
        )
        .sheet(isPresented: self.$showSheet) {
            approveSheet
        }
    }
    
    var approveButton: some View {
        Button {
            self.showSheet = true
        } label: {
            Text("ACCEPT")
                .fontWeight(.bold)
                .font(.headline)
                .foregroundColor(.white)
                .padding(.vertical, 12)
                .padding(.horizontal, 16)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .foregroundColor(ColorConstants.primary)
                )
        }
    }
    
    var rejectButton: some View {
        Button {
//            self.showSheet = true
        } label: {
            Text("REJECT")
                .fontWeight(.bold)
                .font(.headline)
                .foregroundColor(ColorConstants.badgeTextWarning)
                .padding(.vertical, 12)
                .padding(.horizontal, 16)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .foregroundColor(ColorConstants.badgeWarning)
                )
        }
    }
    
    var approveSheet: some View {
        DynamicSheet(
            ZStack {
                VStack(alignment: .leading) {
                    Text("Select permission group")
                        .font(.title)
                        .fontWeight(.light)
                        .padding([.leading, .trailing, .top])
                        .padding([.bottom], 6)
                    
                    PermissionGroupPicker(selectedGroup: $selectedPermissionGroup)
                    
                    Spacer()
                    
                    Button(action: {
                        self.loading = true
                        self.approvalCallback(self.request.requestingUserId, self.selectedPermissionGroup)
                        self.loading = false
                        self.showSheet = false
                    }, label: {
                        Text("ACCEPT")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 24)
                                    .foregroundColor(ColorConstants.primary)
                            )
                            .opacity(self.loading ? 0.5 : 1.0)
                    })
                    .disabled(self.loading)
                    .padding()
                    .padding([.top], 12)
                }.padding(4)
            }
        )
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
