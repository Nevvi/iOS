//
//  ActionableConnectionRequestRow.swift
//  Nevvi
//
//  Created by Tyler Cobb on 12/31/22.
//

import SwiftUI

struct ActionableConnectionRequestRow: View {
    @EnvironmentObject var accountStore: AccountStore
    @EnvironmentObject var connectionsStore: ConnectionsStore
        
    @State var loading: Bool = false
    @State var request: ConnectionRequest
    @State var showSheet: Bool = false
    @State var showDeleteAlert: Bool = false
    @State var selectedPermissionGroup: String = "All Info"
    
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            ProfileImage(imageUrl: request.requesterImage, height: 60, width: 60)
            
            VStack(alignment: .leading, spacing: 6) {
                Text("\(request.requesterFirstName) \(request.requesterLastName)")
                    .font(.system(size: 20, weight: .semibold))
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
        .alert(isPresented: self.$showDeleteAlert) {
            deleteAlert
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
                .padding(.vertical, 10)
                .padding(.horizontal, 16)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .foregroundColor(ColorConstants.primary)
                )
        }
    }
    
    var rejectButton: some View {
        Button {
            self.showDeleteAlert = true
        } label: {
            Text("REJECT")
                .fontWeight(.bold)
                .font(.headline)
                .foregroundColor(ColorConstants.badgeTextWarning)
                .padding(.vertical, 10)
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
                        self.connectionsStore.confirmRequest(otherUserId: self.request.requestingUserId, permissionGroup: self.selectedPermissionGroup) { (result: Result<Bool, Error>) in
                            switch result {
                            case .success(_):
                                self.connectionsStore.loadRequests()
                                self.connectionsStore.load()
                            case .failure(let error):
                                print("Something bad happened", error)
                            }
                        }
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
    
    var deleteAlert: Alert {
        Alert(title: Text("Delete confirmation"), message: Text("Are you sure you want to reject this connection?"), primaryButton: .destructive(Text("Reject")) {
            self.connectionsStore.denyRequest(otherUserId: self.request.requestingUserId) { (result: Result<Bool, Error>) in
                switch result {
                case.success(_):
                    self.connectionsStore.loadRequests()
                case .failure(let error):
                    print("Something bad happened", error)
                }
            }
            
            self.showDeleteAlert = false
        }, secondaryButton: .cancel() {
            self.showDeleteAlert = false
        })
    }
}

struct ActionableConnectionRequestRow_Previews: PreviewProvider {
    static let modelData = ModelData()
    static let accountStore = AccountStore(user: modelData.user)
    static let connectionsStore = ConnectionsStore(connections: modelData.connectionResponse.users,
                                                   requests: modelData.requests,
                                                   blockedUsers: modelData.connectionResponse.users)
    
    static var previews: some View {
        ActionableConnectionRequestRow(request: modelData.requests[0])
            .environmentObject(accountStore)
            .environmentObject(connectionsStore)
    }
}
