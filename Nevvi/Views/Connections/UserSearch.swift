//
//  ConnectionSearch.swift
//  Nevvi
//
//  Created by Tyler Cobb on 12/31/22.
//

import AlertToast
import SwiftUI

struct UserSearch: View {
    @EnvironmentObject var usersStore: UsersStore
    
    @State private var showToast: Bool = false
    @StateObject var nameFilter = DebouncedText()

    var body: some View {
        NavigationView {
            List {
                if self.usersStore.userCount == 0 {
                    if (self.nameFilter.text.count < 3) {
                        Text("Enter at least 3 characters to search for other users")
                            .foregroundColor(.secondary)
                            .fontWeight(.light)
                            .font(.system(size: 18))
                            .multilineTextAlignment(.center)
                    } else {
                        noUsersView
                    }
                } else {
                   usersView
                }
            }
        }
        .scrollContentBackground(self.usersStore.userCount == 0 ? .hidden : .visible)
        .searchable(text: self.$nameFilter.text)
        .navigationBarTitleDisplayMode(.inline)
        .disableAutocorrection(true)
        .onChange(of: self.nameFilter.debouncedText) { text in
            self.usersStore.load(nameFilter: text)
        }
        .onAppear {
            self.nameFilter.text = ""
            self.usersStore.users = []
            self.usersStore.userCount = 0
        }
        .toast(isPresenting: $showToast){
            AlertToast(displayMode: .banner(.slide), type: .complete(Color.green), title: "Request sent!")
        }
    }
    
    var noUsersView: some View {
        HStack {
            Spacer()
            if self.usersStore.loading {
                ProgressView()
            } else {
                VStack {
                    Image(systemName: "person.2.slash")
                        .resizable()
                        .frame(width: 120, height: 100)
                    Text("No users found")
                }
            }
            Spacer()
        }
        .padding([.top], 100)
    }
    
    var usersView: some View {
        ForEach(self.usersStore.users) { user in
            NewConnectionRequestRow(requestCallback: {
                self.showToast = true
            }, user: user)
        }
        .redacted(when: self.usersStore.loading, redactionType: .customPlaceholder)
    }
}

struct UserSearch_Previews: PreviewProvider {
    static let modelData = ModelData()
    static let usersStore = UsersStore(users: modelData.connectionResponse.users)
    
    static var previews: some View {
        UserSearch()
            .environmentObject(usersStore)
    }
}
