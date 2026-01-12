//
//  ActionableConnectionRequestRow.swift
//  Nevvi
//
//  Created by Tyler Cobb on 12/31/22.
//

import SwiftUI
import NukeUI

struct ActionableConnectionRequestRow: View {
    @EnvironmentObject var accountStore: AccountStore
    @EnvironmentObject var connectionsStore: ConnectionsStore
    @EnvironmentObject var connectionGroupsStore: ConnectionGroupsStore
        
    @State var request: ConnectionRequest
    
    @State private var loading: Bool = false
    @State private var showSheet: Bool = false
    @State private var showDeleteAlert: Bool = false
    @State private var selectedPermissionGroup: String = "All Info"
    @State private var selectedConnectionGroups: Set<String> = []
    
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
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 20) {
                HStack(spacing: 16) {
                    LazyImage(url: URL(string: request.requesterImage)) { state in
                        if let image = state.image {
                            image.resizingMode(.aspectFill)
                        } else {
                            Circle().fill(Color.gray.opacity(0.3))
                        }
                    }
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
                    
                    VStack(alignment: .leading) {
                        Text("\(request.requesterFirstName) \(request.requesterLastName)")
                            .font(.headline)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
            }
            
            VStack(spacing: 28) {
                // Permission Group Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Permission Group")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(self.accountStore.permissionGroups, id: \.name) { group in
                                SelectableRow(
                                    title: group.name,
                                    isSelected: self.selectedPermissionGroup == group.name
                                ) {
                                    self.selectedPermissionGroup = group.name
                                }
                            }
                        }
                    }
                    .frame(maxHeight: 250)
                }
                
                // Connection Groups Section
                if !self.connectionGroupsStore.groups.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Add to Groups")
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                        
                        ScrollView {
                            VStack(spacing: 12) {
                                ForEach(self.connectionGroupsStore.groups) { group in
                                    SelectableRow(
                                        title: group.name,
                                        isSelected: selectedConnectionGroups.contains(group.id)
                                    ) {
                                        if selectedConnectionGroups.contains(group.id) {
                                            selectedConnectionGroups.remove(group.id)
                                        } else {
                                            selectedConnectionGroups.insert(group.id)
                                        }
                                    }
                                }
                            }
                        }
                        .frame(maxHeight: 250)
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 24)
            
            Spacer()
            
            // Bottom Button
            VStack(spacing: 0) {
                Divider()
                
                Button(action: confirmConnection) {
                    HStack {
                        Text("Accept Request")
                            .fontWeight(.semibold)
                            .font(.body)
                        
                        if self.loading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.white)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(ColorConstants.primary)
                    )
                    .opacity(self.loading ? 0.6 : 1.0)
                }
                .disabled(self.loading)
                .padding(.horizontal, 24)
                .padding(.vertical, 20)
            }
        }
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
    
    func confirmConnection() {
        loading = true
        connectionsStore.confirmRequest(otherUserId: request.requestingUserId, permissionGroup: selectedPermissionGroup, connectionGroupIds: self.selectedConnectionGroups) { result in
            switch result {
            case .success(_):
                self.connectionsStore.loadRequests()
                self.connectionsStore.load()
            case .failure(let error):
                print("Something bad happened", error)
            }
            loading = false
            showSheet = false
        }
    }
}

struct ActionableConnectionRequestRow_Previews: PreviewProvider {
    static let modelData = ModelData()
    static let accountStore = AccountStore(user: modelData.user)
    static let connectionsStore = ConnectionsStore(connections: modelData.connectionResponse.users,
                                                   requests: modelData.requests,
                                                   blockedUsers: modelData.connectionResponse.users)
    static let connectionGroupsStore = ConnectionGroupsStore(groups: modelData.groups)
    
    static var previews: some View {
        ActionableConnectionRequestRow(request: modelData.requests[0])
            .environmentObject(accountStore)
            .environmentObject(connectionsStore)
            .environmentObject(connectionGroupsStore)
    }
}
