//
//  SuggestedConnectionCard.swift
//  Nevvi
//
//  Created by Tyler Cobb on 12/22/24.
//

import SwiftUI
import NukeUI

struct SuggestedConnectionCard: View {
    @EnvironmentObject var usersStore: UsersStore
    @EnvironmentObject var suggestionsStore: ConnectionSuggestionStore
    @EnvironmentObject var accountStore: AccountStore
    
    var user: Connection
    var requestCallback: () -> Void
    
    @State private var loading: Bool = false
    @State private var showSheet: Bool = false
    @State private var selectedPermissionGroup: String = "All Info"
    
    var body: some View {
        VStack(spacing: 8) {
            // Profile Image
            LazyImage(url: URL(string: user.profileImage)) { state in
                if let image = state.image {
                    image
                        .resizingMode(.aspectFill)
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                }
            }
            .frame(width: 60, height: 60)
            .clipShape(Circle())
            
            // Name
            VStack(spacing: 2) {
                Text(user.firstName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)
                
                if !user.lastName.isEmpty {
                    Text(user.lastName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
            
            // Connect Button
            Button(action: {
                showSheet = true
            }) {
                Text("Connect")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.blue)
                    )
            }
            .opacity(loading ? 0.5 : 1.0)
            .disabled(loading)
        }
        .frame(width: 90)
        .padding(12)
        .background(Color.white)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
        .cornerRadius(12)
        .sheet(isPresented: $showSheet) {
            requestConnectionSheet
        }
    }
    
    var requestConnectionSheet: some View {
        DynamicSheet(
            VStack(alignment: .leading, spacing: 20) {
                // Header
                HStack {
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
                .padding(.horizontal)
                
                // Permission Group Selection
                VStack(alignment: .leading, spacing: 12) {
                    Text("Select permission group")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    PermissionGroupPicker(selectedGroup: $selectedPermissionGroup)
                }
                
                Spacer()
                
                // Request Button
                Button(action: requestConnection) {
                    Text("Request Connection")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 24)
                                .foregroundColor(ColorConstants.primary)
                        )
                        .opacity(loading ? 0.5 : 1.0)
                }
                .disabled(loading)
                .padding(.horizontal)
                .padding(.bottom)
            }
            .padding(.top)
        )
    }
    
    func requestConnection() {
        loading = true
        usersStore.requestConnection(userId: user.id, groupName: selectedPermissionGroup) { result in
            switch result {
            case .success(_):
                requestCallback()
            case .failure(let error):
                print("Failed to request connection: \(error)")
            }
            loading = false
            showSheet = false
        }
    }
}

struct SuggestedConnectionCard_Previews: PreviewProvider {
    static let modelData = ModelData()
    static let usersStore = UsersStore(users: modelData.connectionResponse.users)
    static let suggestionsStore = ConnectionSuggestionStore(users: modelData.connectionResponse.users)
    static let accountStore = AccountStore(user: modelData.user)
    
    static var previews: some View {
        SuggestedConnectionCard(
            user: modelData.connectionResponse.users[0],
            requestCallback: {}
        )
        .environmentObject(usersStore)
        .environmentObject(suggestionsStore)
        .environmentObject(accountStore)
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
