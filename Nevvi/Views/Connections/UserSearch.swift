//
//  ConnectionSearch.swift
//  Nevvi
//
//  Created by Tyler Cobb on 12/31/22.
//

import SwiftUI

struct UserSearch: View {
    @EnvironmentObject var usersStore: UsersStore
    
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
                } else {
                    ForEach(self.usersStore.users) { user in
                        NewConnectionRequestRow(requestCallback: { (id: String, group: String) in
                            self.usersStore.requestConnection(userId: id, groupName: group) { (result: Result<Bool, Error>) in
                                switch result {
                                case .success(_):
                                    print("Requested!")
                                    // probably want to reload here once backend filters out or modifies requested users
                                case .failure(let error):
                                    print("Something bad happened", error)
                                }
                            }
                        }, user: user)
                    }
                    .redacted(when: self.usersStore.loading, redactionType: .customPlaceholder)
                }
            }
        }
        .navigationTitle("Users")
        .navigationBarTitleDisplayMode(.inline)
        .scrollContentBackground(.hidden)
        .searchable(text: self.$nameFilter.text)
        .disableAutocorrection(true)
        .onChange(of: self.nameFilter.debouncedText) { text in
            self.usersStore.load(nameFilter: text)
        }
        .onAppear {
            self.nameFilter.text = ""
            self.usersStore.users = []
            self.usersStore.userCount = 0
        }
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
