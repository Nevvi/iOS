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
        VStack {
            HStack(alignment: .center, spacing: 4) {
                TextField("Search", text: self.$nameFilter.text)
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
                
                Image(systemName: "xmark")
                    .toolbarButtonStyle()
                    .onTapGesture {
                        self.nameFilter.text = ""
                    }
            }
            .padding(.horizontal, 12)
            .padding(.top, 4)
            .padding(.bottom, 12)
            
            if self.usersStore.userCount == 0 {
                if (self.nameFilter.debouncedText.count < 3) {
                    userSearchPrompt
                } else {
                    noUsersView
                }
            } else {
                usersView
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: self.nameFilter.debouncedText) { text in
            self.usersStore.searchByName(nameFilter: text)
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
        VStack {
            Spacer()
            HStack(alignment: .center) {
                if self.usersStore.loading {
                    ProgressView()
                } else {
                    VStack(alignment: .center, spacing: 24) {
                        Image("UpdateProfile")
                        
                        Text("No users found")
                            .defaultStyle(size: 24, opacity: 1.0)
                    }
                    .padding()
                }
            }
            Spacer()
        }
    }
    
    var userSearchPrompt: some View {
        VStack {
            Text("Enter at least 3 characters to search for other users")
                .foregroundColor(.secondary)
                .fontWeight(.light)
                .font(.system(size: 18))
                .multilineTextAlignment(.center)
                .listRowSeparator(.hidden)
            
            Spacer()
        }.padding()
    }
    
    var usersView: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading, spacing: 0) {
                ForEach(self.usersStore.users) { user in
                    NewConnectionRequestRow(requestCallback: {
                        self.showToast = true
                        self.usersStore.removeUser(user: user)
                    }, user: user)
                }
                .redacted(when: self.usersStore.loading, redactionType: .customPlaceholder)
            }
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
