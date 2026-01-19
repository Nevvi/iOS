//
//  InviteUsers.swift
//  Nevvi
//
//  Created by Tyler Cobb on 1/15/23.
//

import SwiftUI
import WrappingHStack

enum InviteReason: String, CaseIterable {
    case wedding = "WEDDING"
    case holidayCards = "HOLIDAY_CARDS"
    case other = "OTHER"
    
    var displayName: String {
        switch self {
        case .wedding: return "Wedding"
        case .holidayCards: return "Holiday Cards"
        case .other: return "Other"
        }
    }
    
    var inviteText: String {
        switch self {
        case .wedding: return """
                Hey! We're collecting addresses for wedding invites using an app called Nevvi. It saves your address so that I only have to bug you once. Would you mind signing up and adding yours?
                
                iPhone app: https://apps.apple.com/us/app/nevvi/id1669915435
                Web: https://nevvi.net
                """
        case .holidayCards: return """
                Hey! We're collecting addresses for holiday cards using an app called Nevvi. It saves your address so that I don't have to bug you again next year. Would you mind signing up and adding yours?
                
                iPhone app: https://apps.apple.com/us/app/nevvi/id1669915435
                Web: https://nevvi.net
                """
        case .other: return """
                Hey! Join me on Nevvi where you never have to ask for an address twice. You enter your information once and it stays updated with anyone you're connected to. 
                
                iPhone: https://apps.apple.com/us/app/nevvi/id1669915435
                Web: https://nevvi.net
                """
        }
    }
}

struct InviteUsers: View {
    @EnvironmentObject var contactStore: ContactStore
    @EnvironmentObject var connectionGroupsStore: ConnectionGroupsStore
    @EnvironmentObject var accountStore: AccountStore
    
    @StateObject var nameFilter = DebouncedText()
    
    @State private var selectedReason: InviteReason = .other
    @State private var selectedPermissionGroup: String = "All Info"
    @State private var selectedConnectionGroups: Set<String> = []
    
    private var filteredUsers: [ContactStore.ContactInfo] {
        return self.contactStore.contactsNotOnNevvi.filter { contact in
            self.nameFilter.debouncedText.isEmpty ||
            "\(contact.firstName) \(contact.lastName)".lowercased().contains(self.nameFilter.debouncedText.lowercased())
        }
    }
    
    var body: some View {
        VStack {
            if !self.contactStore.hasAccess() {
                requestContactsView
            } else {
                contactAccessView
            }
        }
        .onAppear {
            self.nameFilter.text = ""
            if self.contactStore.hasAccess() {
                self.contactStore.loadContacts()
            }
            // Load connection groups for selection
            if self.connectionGroupsStore.groups.isEmpty {
                self.connectionGroupsStore.load()
            }
            
            // Set default permission group if current selection doesn't exist
            if !accountStore.permissionGroups.contains(where: { $0.name == selectedPermissionGroup }),
               let firstGroup = accountStore.permissionGroups.first {
                selectedPermissionGroup = firstGroup.name
            }
        }
        .navigationTitle("Invite")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    var requestContactsView: some View {
        VStack(alignment: .center, spacing: 24) {
            Spacer()
            
            Image("AllowContacts")
            
            Text("Allow Contact Access")
                .defaultStyle(size: 24, opacity: 1.0)
            
            Text("In order to invite users to Nevvi we need access to your contact book to see who is eligible be invited.")
                .defaultStyle(size: 16, opacity: 0.7)
                .multilineTextAlignment(.center)
            
            Text("Consult the privacy policy in the settings for more info on how contacts are used.")
                .defaultStyle(size: 16, opacity: 0.7)
                .multilineTextAlignment(.center)
            
            Spacer()
        }.padding([.leading, .trailing], 24)
    }
    
    var contactAccessView: some View {
        VStack {
            HStack(alignment: .center, spacing: 4) {
                TextField("Search contacts", text: self.$nameFilter.text)
                    .disableAutocorrection(true)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 15.5)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.white)
                    .cornerRadius(40)
                    .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 4)
                    .overlay(
                        RoundedRectangle(cornerRadius: 40)
                            .inset(by: 0.5)
                            .stroke(Color(red: 0, green: 0.07, blue: 0.17).opacity(0.08), lineWidth: 1)
                    )
                
                if !self.nameFilter.text.isEmpty {
                    Image(systemName: "xmark")
                        .toolbarButtonStyle()
                        .onTapGesture {
                            self.nameFilter.text = ""
                        }
                }
            }
            .padding(12)
            
            if self.contactStore.loading {
                loadingUsersView
            } else if (self.filteredUsers.count > 0) {
                inviteUsersView
            } else {
                noUsersView
            }
        }
    }
    
    var loadingUsersView: some View {
        VStack {
            Spacer()
            HStack(alignment: .center) {
                LoadingView(loadingText: "Checking contacts...")
            }
            Spacer()
            Spacer()
        }
    }
    
    var noUsersView: some View {
        VStack {
            Spacer()
            HStack(alignment: .center) {
                VStack(alignment: .center, spacing: 24) {
                    Image("UpdateProfile")
                    
                    Text("No contacts found")
                        .defaultStyle(size: 24, opacity: 1.0)
                }
                .padding()
            }
            Spacer()
            Spacer()
        }
    }
    
    var inviteUsersView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Invite new members")
                            .defaultStyle(size: 20, opacity: 1.0)
                        
                        Text("based on your contacts")
                            .defaultStyle(size: 14, opacity: 0.5)
                    }
                    .padding(0)
                    .frame(width: 257, alignment: .topLeading)
                    
                    Spacer()
                    
                    Text("\(self.filteredUsers.count) \(self.filteredUsers.count == 1 ? "person" : "people")")
                        .defaultStyle(size: 14, opacity: 0.7)
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 4)
                
                ForEach(self.filteredUsers, id: \.phoneNumber) { contact in
                    InviteUserRow(
                        user: contact,
                        selectedReason: self.$selectedReason,
                        selectedPermissionGroup: self.$selectedPermissionGroup,
                        selectedConnectionGroups: self.$selectedConnectionGroups
                    )
                }
                .redacted(when: self.contactStore.loading, redactionType: .customPlaceholder)
            }
        }
        .refreshable {
            if self.contactStore.hasAccess() {
                self.contactStore.loadContacts()
            }
        }
    }
}

struct InviteUserRow: View {
    @State private var showText: Bool = false
    @State private var showSheet: Bool = false
    
    @State private var invited: Bool = false
    @State private var inviting: Bool = false
    @State private var showingStatusText: Bool = false
    
    @State var user: ContactStore.ContactInfo
    
    @Binding var selectedReason: InviteReason
    @Binding var selectedPermissionGroup: String
    @Binding var selectedConnectionGroups: Set<String>
    
    @EnvironmentObject var usersStore: UsersStore
    @EnvironmentObject var connectionGroupsStore: ConnectionGroupsStore
    @EnvironmentObject var accountStore: AccountStore
        
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            if let imageData = user.image {
                Image(uiImage: UIImage(data: imageData)!)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 63, height: 63)
                    .cornerRadius(63)
            } else {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 63, height: 63)
                    .cornerRadius(63)
                    .foregroundColor(.gray)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("\(user.firstName) \(user.lastName)")
                    .defaultStyle(size: 18, opacity: 1.0)
                
                Text("\(user.phoneNumber)")
                    .defaultStyle(size: 14, opacity: 0.7)
                    .multilineTextAlignment(.leading)
            }
            
            Spacer()
            
            VStack(spacing: 4) {
                // Only allow invite if they haven't been invited in this session
                if !self.invited {
                    Button(action: {
                        self.showSheet = true
                    }) {
                        ZStack {
                            Circle()
                                .fill(ColorConstants.primary.opacity(0.1))
                                .frame(width: 32, height: 32)
                            
                            if self.inviting {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: ColorConstants.primary))
                                    .scaleEffect(0.7)
                            } else {
                                Image(systemName: "plus")
                                    .font(.title3)
                                    .foregroundColor(ColorConstants.primary)
                            }
                        }
                    }
                    .padding(.trailing)
                    .disabled(self.inviting)
                } else {
                    // Success state with animated checkmark
                    ZStack {
                        Circle()
                            .fill(Color.green.opacity(0.1))
                            .frame(width: 32, height: 32)
                            .background(
                                Circle()
                                    .fill(Color.green.opacity(0.2))
                                    .scaleEffect(invited ? 1.0 : 0.8)
                                    .animation(.spring(response: 0.6, dampingFraction: 0.6), value: invited)
                            )
                        
                        Image(systemName: "checkmark")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.green)
                            .scaleEffect(invited ? 1.0 : 0.3)
                            .animation(.spring(response: 0.6, dampingFraction: 0.6).delay(0.1), value: invited)
                    }
                    .padding(.trailing)
                }
                
                // Status text that appears and fades
                if self.showingStatusText {
                    Text("Invited")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.green)
                        .transition(.scale.combined(with: .opacity))
                        .padding(.trailing)
                }
            }
        }
        .padding(.vertical, 8)
        .padding(.leading, 16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .overlay(
            Rectangle()
                .inset(by: 0.5)
                .stroke(Color(red: 0, green: 0.07, blue: 0.17).opacity(0.04), lineWidth: 1)
        )
        .sheet(isPresented: self.$showSheet) {
            inviteUserSheet
        }
        .sheet(isPresented: self.$showText) {
            MessageComposeView(
                isPresented: self.$showText,
                recipients: [self.user.phoneNumber],
                body: self.selectedReason.inviteText,
                completion: { result in
                    switch result {
                    case .sent:
                        print("Message Sent")
                        self.showText = false
                        self.inviteUser()
                    case .cancelled:
                        print("Message Cancelled")
                    case .failed:
                        print("Message Failed")
                    @unknown default:
                        fatalError()
                    }
                }
            )
        }
    }
    
    var inviteUserSheet: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 20) {
                HStack(spacing: 16) {
                    if let imageData = user.image {
                        Image(uiImage: UIImage(data: imageData)!)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 56, height: 56)
                            .cornerRadius(28)
                    } else {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 56, height: 56)
                            .cornerRadius(28)
                            .foregroundColor(.secondary)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(user.firstName) \(user.lastName)")
                            .font(.title2)
                            .fontWeight(.semibold)
                        Text(user.phoneNumber)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
            }
            
            VStack(spacing: 28) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Invite Reason")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Picker("Invite Reason", selection: $selectedReason) {
                        ForEach(InviteReason.allCases, id: \.self) { reason in
                            Text(reason.displayName).tag(reason)
                        }
                    }.pickerStyle(.segmented)
                }
                
                // Permission Group Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Permission Group")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Picker("Permission Group", selection: $selectedPermissionGroup) {
                        ForEach(accountStore.permissionGroups, id: \.name) { group in
                            Text(group.name).tag(group.name)
                        }
                    }.pickerStyle(.segmented)
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
                
                Button(action: {
                    self.showSheet = false
                    self.showText = true
                }) {
                    HStack {
                        Text("Send Invitation")
                            .fontWeight(.semibold)
                            .font(.body)
                        
                        if self.inviting {
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
                    .opacity(self.inviting ? 0.6 : 1.0)
                }
                .disabled(self.inviting)
                .padding(.horizontal, 24)
                .padding(.vertical, 20)
            }
        }
    }
    
    func inviteUser() {
        self.inviting = true
        self.usersStore.inviteConnection(phoneNumber: self.user.phoneNumber, permissionGroupName: self.selectedPermissionGroup, connectionGroupIds: self.selectedConnectionGroups) { (result: Result<Bool, Error>) in
            switch result {
            case .success(_):
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8, blendDuration: 0)) {
                    self.invited = true
                    self.showingStatusText = true
                }
                self.inviting = false
                
                // Hide the status text after 2 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        self.showingStatusText = false
                    }
                }
            case .failure(let error):
                print("Failed to invite user", error)
                self.inviting = false
            }
        }
    }
}

struct InviteUsers_Previews: PreviewProvider {
    static let modelData = ModelData()
    static let contactStore = ContactStore(contactsOnNevvi: [], contactsNotOnNevvi: [
        ContactStore.ContactInfo(firstName: "John", lastName: "Doe", phoneNumber: "6129631237"),
        ContactStore.ContactInfo(firstName: "Jane", lastName: "Smith", phoneNumber: "6129631238"),
    ])
    static let connectionGroupsStore = ConnectionGroupsStore(groups: modelData.groups)
    static let accountStore = AccountStore(user: modelData.user)
    static let usersStore = UsersStore(users: modelData.connectionResponse.users)
    
    static var previews: some View {
        InviteUsers()
            .environmentObject(contactStore)
            .environmentObject(connectionGroupsStore)
            .environmentObject(accountStore)
            .environmentObject(usersStore)
    }
}
