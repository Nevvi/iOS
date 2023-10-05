//
//  SwiftUIView.swift
//  Nevvi
//
//  Created by Tyler Standal on 5/21/23.
//

import AlertToast
import SwiftUI

struct OnboardingBulkRequest: View {
    var primaryClick: () -> Void
    var secondaryClick: () -> Void
    
    @EnvironmentObject var accountStore: AccountStore
    @EnvironmentObject var usersStore: UsersStore
    @EnvironmentObject var contactStore: ContactStore
    
    @State private var showToast: Bool = false

    var notConnectedUsers: [Connection] {
        self.usersStore.users.filter {
            $0.connected != nil && !$0.connected! &&
            $0.requested != nil && !$0.requested!
        }
    }
    
    var body: some View {
        VStack {
            Text("Nevvi")
                .onboardingTitle()
                .padding([.bottom], 30)
            
            
            if self.notConnectedUsers.count == 0 {
                Spacer()
                noUsersView
            } else {
                Text("Connect with your phone contacts")
                    .onboardingStyle()
                    .padding([.bottom])
                usersView
            }
            
            Spacer()
            Spacer()
            
            HStack {
                secondaryButton
                
                Spacer()
               
                primaryButton
            }
            .padding([.top, .leading, .trailing])
        }
        .background(BackgroundGradient())
        .scrollContentBackground(self.notConnectedUsers.count == 0 ? .hidden : .visible)
        .navigationBarTitleDisplayMode(.inline)
        .toast(isPresenting: $showToast){
            AlertToast(displayMode: .banner(.slide), type: .complete(Color.green), title: "Request sent!")
        }
        .onAppear {
            self.usersStore.users = []
            self.usersStore.userCount = 0
            self.contactStore.loadContactPhoneNumbers { (result: Result<[String], Error>) in
                switch result {
                case .success(let phoneNumbers):
                    self.usersStore.searchByPhoneNumbers(phoneNumbers: phoneNumbers)
                case .failure(_):
                    // TODO - show some sort of alert
                    self.primaryClick()
                }
            }
        }
    }
    
    var noUsersView: some View {
        HStack {
            Spacer()
            if self.usersStore.loading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: Color.white))
                    .scaleEffect(3.0, anchor: .center)
            } else {
                // TODO - check if we have access to contacts
                NoDataFound(imageName: "person.2.slash", height: 100, width: 120, text: "There are no more contacts in your phone to connect with")
                    .foregroundColor(.white)
            }
            Spacer()
        }
    }
    
    var usersView: some View {
        ScrollView {
            VStack {
                ForEach(self.notConnectedUsers) { user in
                    HStack {
                        NewConnectionRequestRow(requestCallback: {
                            self.showToast = true
                            self.usersStore.removeUser(user: user)
                        }, user: user)
                    }
                    .font(.system(size: 20))
                    .padding([.top, .bottom], 5)
                    .foregroundColor(.white)
                }
                .redacted(when: self.usersStore.loading, redactionType: .customPlaceholder)
            }
            .padding([.leading, .trailing], 20)
        }
    }
    
    var primaryButton: some View {
        Button(action: self.primaryAction, label: {
            HStack {
                Text("Finish")
                    .font(.headline)
                
                Image(systemName: "chevron.right")
            }
            .foregroundColor(ColorConstants.accent)
            .opacity(self.accountStore.saving ? 0.5 : 1.0)
        })
        .disabled(self.accountStore.saving)
    }
    
    var secondaryButton: some View {
        Button(action: self.secondaryClick, label: {
            HStack {
                Image(systemName: "chevron.left")
                
                Text("Back")
                    .font(.headline)
            }
            .foregroundColor(ColorConstants.accent)
        })
    }
    
    func primaryAction() {
        let request = AccountStore.PatchRequest(onboardingCompleted: true)
        self.accountStore.update(request: request) { _ in
            self.primaryClick()
        }
    }
}

struct OnboardingBulkRequest_Previews: PreviewProvider {
    static let modelData = ModelData()
    static let accountStore = AccountStore(user: modelData.user)
    static let usersStore = UsersStore(users: modelData.connectionResponse.users)
    
    static var previews: some View {
        OnboardingBulkRequest(primaryClick: {}, secondaryClick: {})
            .environmentObject(accountStore)
            .environmentObject(usersStore)
            .environmentObject(ContactStore())
    }
}
