//
//  ConnectionList.swift
//  Nevvi
//
//  Created by Tyler Cobb on 12/29/22.
//

import AlertToast
import SwiftUI
import NukeUI
import FirebaseMessaging

struct ConnectionList: View {
    @AppStorage("hasSyncedBefore.v1") var hasSyncedBefore: Bool = false
    
    @EnvironmentObject var connectionsStore: ConnectionsStore
    @EnvironmentObject var accountStore: AccountStore
    @EnvironmentObject var usersStore: UsersStore
    @EnvironmentObject var contactStore: ContactStore
    @EnvironmentObject var notificationStore: NotificationStore
    @EnvironmentObject var connectionStore: ConnectionStore
    @EnvironmentObject var suggestionsStore: ConnectionSuggestionStore
    
    @StateObject private var recentSearchesManager = RecentSearchesManager()
    
    @State private var syncing: Bool = false
    @State private var showSyncConfirmation: Bool = false
    
    @State private var contactsToSyncCount: Int = 0
    @State private var contactUpdates: [ContactStore.ContactSyncInfo] = []
    @State private var showContactUpdates: Bool = false
    
    @State private var showToast: Bool = false
    @State private var toastText: String = ""
    
    @State private var searchText: String = ""
    @State private var searchedText: String = ""
    @State var selectedGroup: String? = nil
    
    @FocusState private var isTextFieldFocused: Bool
    @State private var isSearchActive: Bool = false
    
    private var noConnectionsExist: Bool {
        return self.selectedGroup == nil && self.connectionsStore.connectionCount == 0 && !self.connectionsStore.loading && !isSearchActive
    }
    
    private var syncAvailable: Bool {
        return self.contactStore.hasAccess() && self.connectionsStore.outOfSyncCount > 0
    }
    
    private var showSyncHelper: Bool {
        return self.syncAvailable && !hasSyncedBefore
    }
    
    private var notConnectedSuggestions: [Connection] {
        self.suggestionsStore.users.filter {
            $0.connected != nil && !$0.connected! &&
            $0.requested != nil && !$0.requested!
        }
    }
    
    private var notConnectedUsers: [Connection] {
        self.usersStore.users.filter {
            $0.connected != nil && !$0.connected! &&
            $0.requested != nil && !$0.requested!
        }
    }
        
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if self.notificationStore.canRequestAccess {
                    requestNotificationsView
                } else if self.contactStore.canRequestAccess() {
                    requestContactsView
                } else {
                    searchBar
                    
                    if isSearchActive {
                        searchView
                    } else {
                        browseContent
                    }
                }
            }
            .onChange(of: self.selectedGroup) { group in
                if !isSearchActive {
                    self.connectionsStore.load(nameFilter: nil, permissionGroup: group)
                }
            }
            .refreshable {
                if !isSearchActive {
                    self.connectionsStore.load(nameFilter: nil, permissionGroup: self.selectedGroup)
                    self.connectionsStore.loadOutOfSync { _ in }
                }
            }
            .toolbar(content: {
                ToolbarItemGroup(placement: .topBarLeading) {
                    if self.isSearchActive {
                        Image(systemName: "chevron.left")
                            .toolbarButtonStyle()
                            .onTapGesture {
                                isSearchActive = false
                                isTextFieldFocused = false
                                self.resetSearch()
                                self.connectionsStore.load()
                            }
                    } else if self.syncAvailable {
                        Image(systemName: "arrow.down.circle")
                            .toolbarButtonStyle()
                            .opacity(self.syncing ? 0.5 : 1.0)
                            .disabled(syncing)
                            .onTapGesture {
                                if !self.syncing {
                                    self.sync(dryRun: true)
                                }
                            }
                    }
                }
                
                ToolbarItemGroup(placement: .topBarTrailing) {
                    NavigationLink(destination: ConnectionRequestList()) {
                        ZStack {
                            Image(systemName: "bell")
                                .toolbarButtonStyle()
                            
                            if connectionsStore.requestCount > 0 {
                                Circle()
                                    .fill(Color.red)
                                    .frame(width: 8, height: 8)
                                    .offset(x: 8, y: -8)
                            }
                        }
                    }
                }
            })
            .navigationTitle("Connections")
            .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(isPresented: self.$showContactUpdates) {
            contactUpdatesSheet
        }
        .modifier(Popup(isPresented: self.showSyncHelper) {
            syncHelperSheet
        })
        .toast(isPresenting: $showToast){
            AlertToast(displayMode: .banner(.slide), type: .complete(Color.green), title: self.toastText)
        }
        .onAppear {            
            if self.notificationStore.hasAccess {
                self.updateMessagingToken()
            }
            
            if !showSyncHelper && self.syncAvailable && self.accountStore.deviceSettings.autoSync {
                self.sync(dryRun: true)
            }
        }
    }
    
    var syncHelperSheet: some View {
        VStack(spacing: 24) {
            Image("AppLogo")
                .frame(width: 68, height: 68)
            
            Text("TIP")
                .defaultStyle(size: 16, opacity: 0.5)
            
            Text("You have new data to sync!")
                .defaultStyle(size: 18, opacity: 0.7)
                .multilineTextAlignment(.center)
            
            Text("You can either use the \"Sync\" button at the top of the screen, or enable auto-sync in your profile settings.")
                .defaultStyle(size: 18, opacity: 0.7)
                .multilineTextAlignment(.center)

            Text("Dismiss")
                .asPrimaryButton()
                .onTapGesture {
                    UserDefaults.standard.set(true, forKey: "hasSyncedBefore.v1")
                }
                .padding(.top)
        }
        .frame(maxWidth: 250)
        .padding(32)
        .background(.white)
        .clipped()
        .shadow(color: Color(red: 0.06, green: 0.4, blue: 0.64)
            .opacity(0.16), radius: 30, x: 0, y: 4)
    }
    
    var requestNotificationsView: some View {
        HStack(alignment: .center) {
            VStack(alignment: .center, spacing: 24) {
                Spacer()
                
                Image("NotificationBell")
                
                Text("Allow Notification Access")
                    .defaultStyle(size: 24, opacity: 1.0)
                
                Text("We will only send you important notifications when someone requests you, accepts your request, or changes their information. We will never spam you with unnecessary notifications.")
                    .defaultStyle(size: 16, opacity: 0.7)
                    .multilineTextAlignment(.center)
                
                
                Text("Allow Access".uppercased())
                    .asPrimaryButton()
                    .onTapGesture {
                        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, _ in
                            guard success else {
                                print("Notifications are disabled, not updating token")
                                self.notificationStore.checkRequestAccess()
                                return
                            }
                            
                            self.notificationStore.checkRequestAccess()
                            self.updateMessagingToken()
                        }
                    }
                
                Spacer()
                Spacer()
            }
        }
        .padding()
    }
    
    var requestContactsView: some View {
        HStack(alignment: .center) {
            VStack(alignment: .center, spacing: 24) {
                Spacer()
                
                Image("AllowContacts")
                
                Text("Allow Contact Access")
                    .defaultStyle(size: 24, opacity: 1.0)
                
                Text("Nevvi can detect when your connection data is out of sync with your phone contacts. By giving Nevvi access to your contacts, we can automatically update your phone book with your connection data.")
                    .defaultStyle(size: 16, opacity: 0.7)
                    .multilineTextAlignment(.center)
                
                Text("Consult the privacy policy in the settings for more info on how contacts are used.")
                    .defaultStyle(size: 16, opacity: 0.7)
                    .multilineTextAlignment(.center)
                
                
                Text("Allow Access".uppercased())
                    .asPrimaryButton()
                    .onTapGesture {
                        self.contactStore.tryRequestAccess { result in
                            switch(result) {
                            case .success():
                                print("Got contact access!")
                            case .failure(let error):
                                print("Failed to get contact access: \(error.localizedDescription)")
                            }
                            
                        }
                    }
                
                Spacer()
                Spacer()
            }
        }.padding()
    }
    
    var noConnectionsView: some View {
        GeometryReader { geometry in
            ScrollView(.vertical) {
                VStack(alignment: .center, spacing: 24) {
                    Spacer()
                    
                    Image("UpdateProfile")
                    
                    Text("No connections")
                        .defaultStyle(size: 24, opacity: 1.0)
                    
                    Spacer()
                    Spacer()
                }
                .padding()
                .frame(width: geometry.size.width)
                .frame(minHeight: geometry.size.height)
            }
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
                                .redacted(when: self.contactStore.loading, redactionType: .customPlaceholder)
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
                        .opacity(self.syncing ? 0.5 : 1.0)
                }).disabled(self.syncing)
            }
        }
    }
    
    func updateMessagingToken() -> Void {
        Messaging.messaging().token { token, error in
            if let error = error {
                print("Error fetching FCM registration token: \(error)")
            } else if let token = token {
                if self.notificationStore.token != token {
                    self.notificationStore.updateToken(token: token)
                    print("FCM registration token: \(token)")
                }
            }
        }
        
        UNUserNotificationCenter.current().setBadgeCount(0)
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
                            Text("Updated \(update.changedFields().count) field(s)")
                                .defaultStyle(size: 14, opacity: 0.7)
                        } else {
                            Text("New contact!")
                                .defaultStyle(size: 14, opacity: 0.7)
                        }
                    }
                    
                    Spacer()
                    
                    Image(systemName: "xmark")
                        .toolbarButtonStyle()
                        .padding(.trailing)
                        .onTapGesture {
                            self.contactStore.updateConnection(connectionId: update.connection.id) { result in
                                switch result {
                                case .success(_):
                                    self.contactUpdates.removeAll(where: { u in
                                        update.connection.id == u.connection.id
                                    })
                                    self.connectionsStore.loadOutOfSync { _ in
                                        if self.contactUpdates.isEmpty {
                                            self.showContactUpdates = false
                                        }
                                    }
                                case .failure(let error):
                                    print("Something bad happened", error)
                                }
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
    
    var searchBar: some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                    .font(.system(size: 16))
                
                TextField("Search connections or find new people", text: $searchText)
                    .focused($isTextFieldFocused)
                    .textFieldStyle(PlainTextFieldStyle())
                    .font(.system(size: 16))
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .onChange(of: isTextFieldFocused) { focused in
                        if focused {
                            isSearchActive = true
                        }
                    }
                    .submitLabel(.search)
                    .onSubmit {
                        self.performSearch()
                    }
                
                if !searchText.isEmpty {
                    Button(action: {
                        self.resetSearch()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                            .font(.system(size: 16))
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
            .padding(.horizontal, 14)
            .padding(.top, 8)
            
            Divider()
                .padding(.vertical)
        }
        .background(Color(.systemBackground))
    }
    
    var browseContent: some View {
        VStack {
            if noConnectionsExist {
                noConnectionsView
            } else {
                connectionsListView
            }
        }
    }
    
    var connectionsListView: some View {
        VStack {
            ScrollView(.vertical) {
                VStack {
                    ScrollView(.horizontal) {
                        HStack(spacing: 6) {
                            ForEach(self.accountStore.permissionGroups, id: \.name) { group in
                                if group.name.uppercased() == self.selectedGroup?.uppercased() {
                                    Text(group.name.uppercased())
                                        .asSelectedGroupFilter()
                                        .opacity(self.connectionsStore.loading ? 0.7 : 1.0)
                                        .onTapGesture {
                                            if !self.connectionsStore.loading {
                                                self.selectedGroup = nil
                                            }
                                        }
                                } else {
                                    Text(group.name.uppercased())
                                        .asGroupFilter()
                                        .opacity(self.connectionsStore.loading ? 0.7 : 1.0)
                                        .onTapGesture {
                                            if !self.connectionsStore.loading {
                                                self.selectedGroup = group.name
                                            }
                                        }
                                }
                            }
                        }
                        .padding(.vertical, 4)
                        .padding(.horizontal, 20)
                    }
                    
                    
                    LazyVStack(alignment: .leading, spacing: 0) {
                        HStack {
                            Text("Total Members (\(self.connectionsStore.connectionCount))")
                                .defaultStyle(size: 14, opacity: 0.4)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 6)
                            
                            Spacer()
                        }
                        
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
                                    .onAppear {
                                        let isLast = connection == self.connectionsStore.connections.last
                                        if isLast && self.connectionsStore.hasNextPage() && !self.connectionsStore.loadingPage {
                                            self.connectionsStore.loadNextPage()
                                        }
                                    }
                            }
                        }
                        .redacted(when: self.connectionsStore.loading || self.connectionStore.deleting, redactionType: .customPlaceholder)
                        
                        if self.connectionsStore.loadingPage {
                            HStack(alignment: .center) {
                                Spacer()
                                ProgressView()
                                Spacer()
                            }
                            .padding(.vertical)
                        }
                    }
                    
                    Spacer()
                }
            }
        }
        .disableAutocorrection(true)
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
                        let validUpdates = syncInfo.updatedContacts.filter { updates in
                            return updates.changedFields().count > 0
                        }
                        
                        self.contactUpdates.append(contentsOf: validUpdates)

                        if (!dryRun) {
                            UIApplication.shared.applicationIconBadgeNumber = 0
                            self.contactsToSyncCount = 0
                            self.connectionsStore.loadOutOfSync { _ in }
                            self.toastText = "Contacts synced!"
                            self.showToast = true
                        } else if self.contactUpdates.count > 0 {
                            self.contactsToSyncCount = self.contactUpdates.count
                            self.showContactUpdates = true
                        } else {
                            // Sometimes the server thinks something changed but the contact book
                            // is already up to date. In this case just sync to update the server.
                            self.sync(dryRun: false)
                        }

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
    
    var searchView: some View {
        VStack(spacing: 0) {
            if self.usersStore.loading || self.connectionsStore.loading {
                VStack(alignment: .center) {
                    Spacer()
                    LoadingView(loadingText: "Searching...")
                        .padding(.bottom, 48)
                    Spacer()
                }
            } else if self.searchedText.isEmpty {
                searchEmptyState
            } else {
                searchResults
            }
        }
        .refreshable {
            if !self.searchedText.isEmpty {
                self.suggestionsStore.loadSuggestions()
            } else {
                self.performSearch()
            }
        }
    }
    
    private func performSearch() {
        connectionsStore.load(nameFilter: searchText, permissionGroup: nil)
        usersStore.searchByName(nameFilter: searchText)
        self.searchedText = self.searchText
        recentSearchesManager.addRecentSearch(searchText)
    }
    
    private func resetSearch() {
        self.searchText = ""
        self.searchedText = ""
        self.usersStore.users = []
        self.usersStore.userCount = 0
        self.connectionsStore.connections = []
        self.connectionsStore.connectionCount = 0
    }
    
    var searchEmptyState: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Recent Searches Section
                if !recentSearchesManager.recentSearches.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Recent Searches")
                                .font(.headline)
                                .fontWeight(.semibold)
                            Spacer()
                            Button("Clear") {
                                recentSearchesManager.clearRecentSearches()
                            }
                            .font(.caption)
                            .foregroundColor(.blue)
                        }
                        .padding(.horizontal, 16)
                        
                        VStack(spacing: 8) {
                            ForEach(recentSearchesManager.recentSearches) { search in
                                RecentSearchRow(searchTerm: search.searchTerm, subtitle: "Recent search")
                                    .onTapGesture {
                                        self.searchText = search.searchTerm
                                        self.performSearch()
                                    }
                            }
                        }
                    }
                }
                
                // Suggested Connections Section
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Suggested Connections")
                            .font(.headline)
                            .fontWeight(.semibold)
                        Spacer()
                        if suggestionsStore.loading {
                            ProgressView()
                                .scaleEffect(0.7)
                        } else {
                            Text("\(notConnectedSuggestions.count)")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.horizontal, 16)
                    
                    if notConnectedSuggestions.count > 0 {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(notConnectedSuggestions.prefix(8)) { user in
                                    SuggestedConnectionCard(user: user) {
                                        self.toastText = "Request sent!"
                                        showToast = true
                                        suggestionsStore.loadSuggestions()
                                    }
                                }
                                .redacted(when: suggestionsStore.loading, redactionType: .customPlaceholder)
                            }
                            .padding(.horizontal, 16)
                        }
                    }
                }
                
                Spacer(minLength: 100)
            }
        }
    }
    
    var searchResults: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // No Results State
                if connectionsStore.connections.isEmpty && usersStore.users.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "person.2.slash")
                            .font(.system(size: 50))
                            .foregroundColor(.gray.opacity(0.6))
                        
                        VStack(spacing: 8) {
                            Text("No results found")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            Text("Try adjusting your search terms")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
                } else {
                    VStack(alignment: .leading, spacing: 12) {
                        // Connections section
                        if !self.connectionsStore.connections.isEmpty {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Your Connections")
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                    Text("People you're already connected with")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Text("\(connectionsStore.connectionCount)")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal, 16)
                        }
                        
                        if !self.connectionsStore.connections.isEmpty {
                            VStack(spacing: 0) {
                                ForEach(connectionsStore.connections.prefix(3)) { connection in
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
                            }
                        }
                        
                        if connectionsStore.connectionCount > 3 {
                            NavigationLink {
                                ConnectionSearchResults()
                            } label: {
                                HStack {
                                    Text("See all \(connectionsStore.connections.count) connection results")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(.blue)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundColor(.blue)
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(Color.blue.opacity(0.05))
                            }
                        }
                        
                        // New People Section
                        if !notConnectedUsers.isEmpty {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("New People")
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                    Text("People you can connect with")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Text("\(notConnectedUsers.count)")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal, 16)
                        }
                        
                        if !notConnectedUsers.isEmpty {
                            VStack(spacing: 0) {
                                ForEach(notConnectedUsers.prefix(10)) { user in
                                    NewConnectionRequestRow(requestCallback: {
                                        self.toastText = "Request sent!"
                                        showToast = true
                                        usersStore.removeUser(user: user)
                                    }, user: user)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

struct RecentSearchRow: View {
    let searchTerm: String
    let subtitle: String
    
    var body: some View {
        HStack {
            Image(systemName: "clock")
                .foregroundColor(.gray)
                .font(.system(size: 16))
            
            VStack(alignment: .leading, spacing: 2) {
                Text(searchTerm)
                    .font(.subheadline)
                    .foregroundColor(.primary)
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "arrow.up.left")
                .foregroundColor(.gray)
                .font(.system(size: 14))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
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
    static let notificationStore = NotificationStore()
    static let accountStore = AccountStore(user: modelData.user)
    static let suggestionsStore = ConnectionSuggestionStore(users: modelData.connectionResponse.users)
    
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
            .environmentObject(notificationStore)
            .environmentObject(suggestionsStore)
    }
}
