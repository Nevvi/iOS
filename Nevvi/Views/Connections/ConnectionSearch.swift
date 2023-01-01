//
//  ConnectionSearch.swift
//  Nevvi
//
//  Created by Tyler Cobb on 12/31/22.
//

import SwiftUI

struct ConnectionSearch: View {
    @ObservedObject var accountStore: AccountStore
    @ObservedObject var usersStore: UsersStore
    @StateObject var nameFilter = DebouncedText()

    
    var body: some View {
        NavigationView {
            List {
                ForEach(self.usersStore.users) { user in
                    NewConnectionRequestRow(accountStore: self.accountStore, requestCallback: { (id: String, group: String) in
                        self.usersStore.requestConnection(userId: id, groupName: group)
                    }, user: user)
                }
            }.navigationTitle("Users")
        }
        .searchable(text: self.$nameFilter.text)
        .onChange(of: self.nameFilter.debouncedText) { text in
            self.usersStore.load(nameFilter: text)
        }
    }
}

struct ConnectionSearch_Previews: PreviewProvider {
    static let modelData = ModelData()
    static let accountStore = AccountStore()
    static let usersStore = UsersStore(users: modelData.connectionResponse.users)
    
    static var previews: some View {
        ConnectionSearch(accountStore: accountStore, usersStore: usersStore)
    }
}
