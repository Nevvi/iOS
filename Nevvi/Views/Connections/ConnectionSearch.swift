//
//  ConnectionSearch.swift
//  Nevvi
//
//  Created by Tyler Cobb on 12/31/22.
//

import SwiftUI

struct ConnectionSearch: View {
    @ObservedObject var usersStore: UsersStore
    @StateObject var nameFilter = DebouncedText()

    @State private var showError: Bool = false
    @State private var error: Error? = nil
    
    @State private var shimmering: Bool = false
    
    var body: some View {
        NavigationView {
            List {
                if self.usersStore.userCount == 0 && self.usersStore.loading == false && self.nameFilter.text.count >= 3 {
                    HStack {
                        Spacer()
                        VStack {
                            Image(systemName: "person.2.slash")
                                .resizable()
                                .frame(width: 100, height: 100)
                            Text("No users found")
                        }
                        Spacer()
                    }
                    .padding([.top], 50)
                } else if self.usersStore.loading {
                    ForEach((1...5), id: \.self) { _ in
                        HStack {
                            Image(systemName: "person")
                                .frame(width: 50, height: 50)
                                .clipShape(Circle())
                            
                            Text("Dummy Request Text")
                        }
                        .padding(5)
                    }
                    .redacted(reason: .placeholder)
                    .foregroundStyle(.linearGradient(colors: [.gray, .black],
                                                     startPoint: .leading,
                                                     endPoint: self.shimmering ? .trailing : .leading)
                    )
                    .animation(.easeInOut(duration: 0.5).repeatForever(autoreverses: false),
                               value: self.shimmering)
                } else {
                    ForEach(self.usersStore.users) { user in
                        NewConnectionRequestRow(requestCallback: { (id: String, group: String) in
                            self.usersStore.requestConnection(userId: id, groupName: group) { (result: Result<Bool, Error>) in
                                switch result {
                                case .success(_):
                                    print("Requested!")
                                    // probably want to reload here once backend filters out or modifies requested users
                                case .failure(let error):
                                    self.error = error
                                    self.showError = true
                                }
                            }
                        }, user: user)
                    }
                }
            }
            .navigationTitle("Users")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                self.shimmering.toggle()
            }
        }
        .scrollContentBackground(.hidden)
        .searchable(text: self.$nameFilter.text)
        .disableAutocorrection(true)
        .alert(isPresented: self.$showError) {
            Alert(title: Text("Something went wrong"), message: Text(self.error!.localizedDescription))
        }
        .onChange(of: self.nameFilter.debouncedText) { text in
            self.usersStore.load(nameFilter: text)
        }
    }
}

struct ConnectionSearch_Previews: PreviewProvider {
    static let modelData = ModelData()
    static let usersStore = UsersStore(users: modelData.connectionResponse.users)
    
    static var previews: some View {
        ConnectionSearch(usersStore: usersStore)
    }
}
