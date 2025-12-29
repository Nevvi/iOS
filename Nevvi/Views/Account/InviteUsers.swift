//
//  InviteUsers.swift
//  Nevvi
//
//  Created by Tyler Cobb on 1/15/23.
//

import AlertToast
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
}

struct InviteUsers: View {
    @EnvironmentObject var contactStore: ContactStore
    @State private var toastText: String = ""
    @State private var showToast: Bool = false
    @StateObject var nameFilter = DebouncedText()
    @State private var selectedReason: InviteReason = .other
    
    private var inviteUsers: [ContactStore.ContactInfo] {
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
        .toast(isPresenting: $showToast){
            AlertToast(displayMode: .banner(.slide), type: .complete(Color.green), title: self.toastText)
        }
        .onAppear {
            self.nameFilter.text = ""
            if self.contactStore.hasAccess() {
                self.contactStore.loadContacts()
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
            } else if (self.inviteUsers.count > 0) {
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
                    
                    Text("\(self.inviteUsers.count) \(self.inviteUsers.count == 1 ? "person" : "people")")
                        .defaultStyle(size: 14, opacity: 0.7)
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 4)
                
                ForEach(self.inviteUsers, id: \.phoneNumber) { contact in
                    ConnectionInviteRow(
                        requestCallback: {
                            self.toastText = "Invite sent!"
                            self.showToast = true
                            self.contactStore.removeContactNotOnNevvi(phoneNumber: contact.phoneNumber)
                        },
                        selectedReason: self.$selectedReason,
                        user: contact
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

struct InviteUsers_Previews: PreviewProvider {
    static let modelData = ModelData()
    static let contactStore = ContactStore(contactsOnNevvi: [], contactsNotOnNevvi: [
        ContactStore.ContactInfo(firstName: "John", lastName: "Doe", phoneNumber: "6129631237"),
        ContactStore.ContactInfo(firstName: "Jane", lastName: "Doe", phoneNumber: "6129631238"),
    ])
    
    static var previews: some View {
        InviteUsers()
            .environmentObject(contactStore)
    }
}
