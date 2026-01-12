//
//  ConnectionRequest.swift
//  Nevvi
//
//  Created by Tyler Cobb on 12/31/22.
//

import SwiftUI
import NukeUI

struct NewConnectionRequestRow: View {
    @EnvironmentObject var accountStore: AccountStore
    @EnvironmentObject var usersStore: UsersStore
    @EnvironmentObject var connectionGroupsStore: ConnectionGroupsStore
    
    var requestCallback: () -> Void
        
    @State var user: Connection
    @State var loading: Bool = false
    @State var showSheet: Bool = false
    @State private var animate = false
    @State var selectedPermissionGroup: String = "All Info"
    @State var selectedConnectionGroups: Set<String> = []
    
    var showConnectButton: Bool {
        if (user.connected != nil && user.connected!) {
            return false
        }
        
        if (user.requested != nil && user.requested!) {
            return false
        }
        
        return true
    }
    
    var body: some View {
        ZStack(alignment: .trailing) {
            ConnectionRow(connection: self.user)
            
            Spacer()
            
            if showConnectButton {
                Image(systemName: "plus")
                    .toolbarButtonStyle()
                    .onTapGesture {
                        self.showSheet = true
                    }
                    .padding()
            }
        }
        .sheet(isPresented: self.$showSheet) {
            requestConnectionSheet
        }
    }
    
    var requestConnectionSheet: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 20) {
                HStack(spacing: 16) {
                    LazyImage(url: URL(string: user.profileImage)) { state in
                        if let image = state.image {
                            image.resizingMode(.aspectFill)
                        } else {
                            Circle().fill(Color.gray.opacity(0.3))
                        }
                    }
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
                    
                    VStack(alignment: .leading) {
                        Text("\(user.firstName) \(user.lastName)")
                            .font(.headline)
                        if let bio = user.bio, !bio.isEmpty {
                            Text(bio)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .lineLimit(2)
                        }
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
                
                // Connection Groups Section
                if !self.connectionGroupsStore.groups.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Add to Groups")
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                        
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
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 24)
            
            Spacer()
            
            // Bottom Button
            VStack(spacing: 0) {
                Divider()
                
                Button(action: requestConnection) {
                    HStack {
                        Text("Request Connection")
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
    
    func requestConnection() {
        self.loading = true
        self.usersStore.requestConnection(userId: self.user.id, groupName: self.selectedPermissionGroup, connectionGroupIds: self.selectedConnectionGroups) { (result: Result<Bool, Error>) in
            switch result {
            case .success(_):
                withAnimation(Animation.spring().speed(0.75)) {
                    animate = true
                    self.requestCallback()
                }
            case .failure(let error):
                print("Something bad happened", error)
            }
            self.loading = false
            self.showSheet = false
        }
    }
    
}

struct ConnectionRequest_Previews: PreviewProvider {
    static let modelData = ModelData()
    static let usersStore = UsersStore(users: modelData.connectionResponse.users)
    static let accountStore = AccountStore(user: modelData.user)
    static let connectionGroupsStore = ConnectionGroupsStore(groups: modelData.groups)
    
    static var previews: some View {
        NewConnectionRequestRow(requestCallback: {},user: modelData.connectionResponse.users[0])
            .environmentObject(usersStore)
            .environmentObject(accountStore)
            .environmentObject(connectionGroupsStore)
    }
}
