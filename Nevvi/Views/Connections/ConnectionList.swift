//
//  ConnectionList.swift
//  Nevvi
//
//  Created by Tyler Cobb on 12/29/22.
//

import SwiftUI
import NukeUI

struct ConnectionList: View {
    @EnvironmentObject var connectionsStore: ConnectionsStore
    @EnvironmentObject var accountStore: AccountStore
    @EnvironmentObject var usersStore: UsersStore
    @EnvironmentObject var contactStore: ContactStore
    @EnvironmentObject var connectionStore: ConnectionStore
    
    @State private var syncing: Bool = false
    @State private var showSyncConfirmation: Bool = false
    
    @State private var contactsToSyncCount: Int = 2
//    @State private var contactUpdates: [ContactStore.ContactSyncInfo] = []
    @State private var contactUpdates: [ContactStore.ContactSyncInfo] = [
        ContactStore.ContactSyncInfo(
            connection: Connection(
                id: "abc",
                firstName: "Tyler",
                lastName: "Standal",
                profileImage: "https://nevvi-user-images-dev.s3.amazonaws.com/Default_Profile_Picture.png"
            ),
            updatedFields: [
                ContactStore.ContactSyncFieldInfo(field: "firstName", oldValue: "Ty", newValue: "Tyler"),
                ContactStore.ContactSyncFieldInfo(field: "lastName", oldValue: "Cobb", newValue: "Standal")
            ],
            isUpdate: true
        ),
        ContactStore.ContactSyncInfo(
            connection: Connection(
                id: "bcd",
                firstName: "Tyler2",
                lastName: "Standal2",
                profileImage: "https://nevvi-user-images-dev.s3.amazonaws.com/Default_Profile_Picture.png"
            ),
            updatedFields: [
                ContactStore.ContactSyncFieldInfo(field: "firstName", oldValue: nil, newValue: "Tyler2"),
                ContactStore.ContactSyncFieldInfo(field: "lastName", oldValue: nil, newValue: "Standal2")
            ],
            isUpdate: false
        )
    ]
    @State private var showContactUpdates: Bool = true
    
    @StateObject var nameFilter = DebouncedText()
    @State var selectedGroup: String = "ALL"
        
    var body: some View {
        NavigationView {
            VStack {
                if self.contactStore.canRequestAccess() {
                    requestContactsView
                } else if self.accountStore.firstName.isEmpty {
                    profileUpdateView
                } else if self.nameFilter.text.isEmpty && self.connectionsStore.connectionCount == 0 {
                    noConnectionsView
                } else {
                    connectionsView
                }
            }
            .navigationTitle("Connections")
            .navigationBarTitleDisplayMode(.large)
            .toolbar(content: {
                if self.contactStore.hasAccess() && self.connectionsStore.outOfSyncCount > 0 {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Image(systemName: "square.and.arrow.down")
                            .toolbarButtonStyle()
                            .onTapGesture {
                                if !self.syncing {
                                    self.sync(dryRun: true)
                                }
                            }
                            .opacity(self.syncing ? 0.5 : 1.0)
                    }
                }
            })
        }
        .sheet(isPresented: self.$showContactUpdates) {
            contactUpdatesSheet
        }
    }
    
    var requestContactsView: some View {
        HStack(alignment: .center) {
            VStack(alignment: .center, spacing: 24) {
                Spacer()
                
                Image("AllowContacts")
                
                Text("Allow Contact Access")
                    .defaultStyle(size: 24, opacity: 1.0)
                
                Text("Your privacy is our priority. We only use your contacts to suggest relevant connections, and sync the latest connection data, never for spam.")
                    .defaultStyle(size: 16, opacity: 0.7)
                    .multilineTextAlignment(.center)
                
                
                Text("Allow Access".uppercased())
                    .asPrimaryButton()
                    .onTapGesture {
                        let result = self.contactStore.tryRequestAccess()
                        if result {
                            print("Got contact access!")
                        } else {
                            print("Failed to get contact access")
                        }
                    }
                
                Spacer()
                Spacer()
            }
            .padding()
        }.padding()
    }
    
    var profileUpdateView: some View {
        HStack(alignment: .center) {
            VStack(alignment: .center, spacing: 24) {
                Spacer()
                
                Image("UpdateProfile")
                
                Text("Update Your Profile")
                    .defaultStyle(size: 24, opacity: 1.0)
                
                // 16/Regular
                Text("You're almost there! Finish your profile and get the best experience with your connection members.")
                    .defaultStyle(size: 16, opacity: 0.7)
                    .multilineTextAlignment(.center)
                
                
                NavigationLink(destination: PersonalInformationEdit()) {
                    Text("Update Profile".uppercased())
                        .asPrimaryButton()
                }
                
                Spacer()
                Spacer()
            }
            .padding()
        }.padding()
    }
    
    var noConnectionsView: some View {
        HStack(alignment: .center) {
            VStack(alignment: .center, spacing: 24) {
                Spacer()
                
                Image("UpdateProfile")
                
                Text("No connections")
                    .defaultStyle(size: 24, opacity: 1.0)
                
                // 16/Regular
                Text("Let's find some people for you to connect with.")
                    .defaultStyle(size: 16, opacity: 0.7)
                    .multilineTextAlignment(.center)
                
                NavigationLink(destination: UserSearch()) {
                    Text("Find Connections".uppercased())
                        .asPrimaryButton()
                }
                
                Spacer()
                Spacer()
            }
            .padding()
        }.padding()
    }
    
    var connectionsView: some View {
        ScrollView(.vertical) {
            VStack {
                ScrollView(.horizontal) {
                    HStack(spacing: 6) {
                        ForEach(self.accountStore.permissionGroups, id: \.name) { group in
                            if group.name.uppercased() == self.selectedGroup.uppercased() {
                                Text(group.name.uppercased())
                                    .asSelectedGroupFilter()
                            } else {
                                Text(group.name.uppercased())
                                    .asGroupFilter()
                                    .onTapGesture {
                                        self.selectedGroup = group.name
                                    }
                            }
                        }
                    }
                    .padding(.vertical, 4)
                    .padding(.horizontal, 20)
                }
                
                
                VStack(alignment: .leading, spacing: 0) {
                    Text("Total Members (\(self.connectionsStore.connectionCount))")
                        .defaultStyle(size: 14, opacity: 0.4)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 6)
                        .frame(width: .infinity, alignment: .center)
                    
                    ForEach(self.connectionsStore.connections) { connection in
                        NavigationLink {
                            NavigationLazyView(
                                ConnectionDetail()
                                    .onAppear {
                                        loadConnection(connectionId: connection.id)
                                    }
                            )
                        } label: {
                            ConnectionRow(connection: connection)
                        }
                    }
                    .redacted(when: self.connectionsStore.loading || self.connectionStore.deleting, redactionType: .customPlaceholder)
                }
                .frame(width: .infinity, alignment: .topLeading)
                
                Spacer()
            }
        }
        .navigationTitle("Connections")
        .navigationBarTitleDisplayMode(.large)
        .searchable(text: self.$nameFilter.text)
        .disableAutocorrection(true)
        .onChange(of: self.nameFilter.debouncedText) { text in
            self.connectionsStore.load(nameFilter: text, permissionGroup: self.selectedGroup)
        }
        .onChange(of: self.selectedGroup) { group in
            self.connectionsStore.load(nameFilter: self.nameFilter.text, permissionGroup: group)
        }
        .refreshable {
            self.connectionsStore.load(nameFilter: self.nameFilter.debouncedText, permissionGroup: self.selectedGroup)
            self.connectionsStore.loadOutOfSync { _ in }
        }
    }
    
    var contactUpdatesSheet: some View {
        VStack {
            Text("\(self.contactUpdates.count) contact(s) to sync")
                .defaultStyle()
                .fontWeight(.semibold)
                .padding()
                        
            ScrollView {
                VStack {
                    ForEach(self.contactUpdates, id: \.self.connection.id) { (update: ContactStore.ContactSyncInfo) in
                        if (update.changedFields().count > 0) {
                            updatedConnectionView(update: update)
                        }
                    }
                }
            }
            
            Spacer()
            
            if (self.contactsToSyncCount > 0) {
                Button(action: {
                    self.sync(dryRun: false)
                }, label: {
                    Text("Sync")
                        .asPrimaryButton()
                        .padding()
                })
            }
        }
    }
    
    func updatedConnectionView(update: ContactStore.ContactSyncInfo) -> some View {
        VStack(alignment: .leading) {
            ZStack(alignment: .trailing) {
                HStack(alignment: .center, spacing: 12) {
                    ZStack(alignment: .bottom) {
                        Rectangle()
                        .foregroundColor(.clear)
                        .frame(width: 63, height: 63)
                        .background(
                            LazyImage(url: URL(string: update.connection.profileImage), resizingMode: .aspectFill)
                        )
                        .cornerRadius(63)
                        .padding([.bottom], 8)
                                        
                        Text(update.connection.permissionGroup ?? "Unknown")
                            .asPermissionGroupBadge(bgColor: Color(red: 0.82, green: 0.88, blue: 1))
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("\(update.connection.firstName) \(update.connection.lastName)")
                            .defaultStyle(size: 18, opacity: 1.0)
                        
                        if (update.isUpdate) {
                            Text("Updated \(update.changedFields().count) fields")
                                .defaultStyle(size: 14, opacity: 0.7)
                        } else {
                            Text("New contact!")
                                .defaultStyle(size: 14, opacity: 0.7)
                        }
                    }
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .overlay(
                    Rectangle()
                        .inset(by: 0.5)
                        .stroke(Color(red: 0, green: 0.07, blue: 0.17).opacity(0.04), lineWidth: 1)
                )
            }
        }
    }
    
    func loadConnection(connectionId: String) {
        self.connectionStore.load(connectionId: connectionId) { (result: Result<Connection, Error>) in
            switch result {
            case .success(_):
                print("Got connection \(connectionId)")
            case .failure(let error):
                print("Something bad happened", error)
            }
        }
    }
    
    func sync(dryRun: Bool) {
        self.syncing = true
        self.showContactUpdates = false
        self.contactUpdates = []
        
        print("Syncing... Dry Run: \(dryRun)")
        
        self.connectionsStore.loadOutOfSync { (result: Result<ConnectionResponse, Error>) in
            switch result {
            case .success(let response):
                print("Got response: \(response)")
                if response.count > 0 {
                    self.contactStore.syncContacts(connections: response.users, dryRun: dryRun) { syncInfo in
                        self.contactUpdates.append(contentsOf: syncInfo.updatedContacts)

                        if (!dryRun) {
                            UIApplication.shared.applicationIconBadgeNumber = 0
                            self.contactsToSyncCount = 0
                            self.connectionsStore.loadOutOfSync { _ in }
                        } else {
                            self.contactsToSyncCount = self.contactUpdates.count
                        }

                        self.showContactUpdates = true
                        self.syncing = false
                    }
                } else {
                    self.syncing = false
                }
            case .failure(let error):
                print("Something bad happened", error.localizedDescription)
                self.contactUpdates = []
                self.syncing = false
            }
        }
    }
}

struct ConnectionList_Previews: PreviewProvider {
    static let modelData = ModelData()
    static let usersStore = UsersStore(users: modelData.connectionResponse.users)
    static let connectionsStore = ConnectionsStore(connections: modelData.connectionResponse.users,
                                                   requests: modelData.requests,
                                                   blockedUsers: modelData.connectionResponse.users)
    static let connectionStore = ConnectionStore()
    static let contactStore = ContactStore()
    static let accountStore = AccountStore(user: modelData.user)
    
    /**
     @State private var contactUpdates: [ContactStore.ContactSyncInfo] = [
         ContactStore.ContactSyncInfo(
             connection: Connection(
                 id: "abc",
                 firstName: "Tyler",
                 lastName: "Standal",
                 profileImage: "https://nevvi-user-images-dev.s3.amazonaws.com/Default_Profile_Picture.png"
             ),
             updatedFields: [
                 ContactStore.ContactSyncFieldInfo(field: "firstName", oldValue: "Ty", newValue: "Tyler"),
                 ContactStore.ContactSyncFieldInfo(field: "lastName", oldValue: "Cobb", newValue: "Standal")
             ],
             isUpdate: true
         ),
         ContactStore.ContactSyncInfo(
             connection: Connection(
                 id: "bcd",
                 firstName: "Tyler2",
                 lastName: "Standal2",
                 profileImage: "https://nevvi-user-images-dev.s3.amazonaws.com/Default_Profile_Picture.png"
             ),
             updatedFields: [
                 ContactStore.ContactSyncFieldInfo(field: "firstName", oldValue: "Ty", newValue: "Tyler2"),
                 ContactStore.ContactSyncFieldInfo(field: "lastName", oldValue: "Cobb", newValue: "Standal2")
             ],
             isUpdate: false
         )
     ]
     */
    
    static var previews: some View {
        ConnectionList()
            .environmentObject(connectionsStore)
            .environmentObject(usersStore)
            .environmentObject(contactStore)
            .environmentObject(accountStore)
            .environmentObject(connectionStore)
    }
}
