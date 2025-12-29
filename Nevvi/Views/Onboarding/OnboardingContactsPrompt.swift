//
//  OnboardingViewFour.swift
//  Nevvi
//
//  Created by Tyler Cobb on 12/30/22.
//

import Contacts
import SwiftUI

struct OnboardingContactsPrompt: View {
    @EnvironmentObject var contactStore: ContactStore
    
    @State var showContactPrompt: Bool = true
    
    var primaryClick: () -> Void
    
    var body: some View {
        if self.showContactPrompt {
            contactsPrompt
        } else {
            contactsInvite
        }
    }
    
    var contactsPrompt: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 0) {
                    Image("ContactDiscoveryPrompt")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geometry.size.width, height: geometry.size.height * 0.63)
                        .clipped()
                        .ignoresSafeArea(.all, edges: .horizontal)
                        .padding(.bottom)
                    
                    VStack(spacing: 10) {
                        Text("Find people you know")
                            .defaultStyle(size: 30)
                            .fontWeight(.bold)
                        
                        Text("See which of your contacts are already using Nevvi so you can instantly connect.")
                            .defaultStyle(size: 16)
                            .multilineTextAlignment(.center)
                        
                        VStack(spacing: 6) {
                            Image(systemName: "checkmark.shield.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.green)
                            
                            Text("We need access to all your contacts just to find potential matches. We never store your contact list or share that information.")
                                .defaultStyle(size: 14)
                                .fontWeight(.light)
                                .multilineTextAlignment(.center)
                        }
                        .padding()
                        .background(Color(UIColor(hexString: "#E8FAF4")))
                        .cornerRadius(16)
                        .padding([.leading, .trailing, .bottom])
                    }
                    .padding([.leading, .trailing])
                    
                    OnboardingButton(text: "I'll Add People Manually", primary: false, action: self.primaryClick)
                        .padding(.bottom, -16)
                    OnboardingButton(text: "Find My Contacts", action: self.requestAccess)
                }
            }
            .edgesIgnoringSafeArea(.top)
        }
    }
    
    var contactsInvite: some View {
        GeometryReader { geometry in
            ZStack {
                Image("BackgroundBlur")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
                    .ignoresSafeArea(.all, edges: .horizontal)
                
                VStack(alignment: .center, spacing: 12) {
                    if self.contactStore.loading {
                        LoadingView(loadingText: "Hang tight while we check your contacts...")
                    } else if (self.contactStore.contactsOnNevvi.count == 0) {
                        noUsersView
                    } else {
                        loadedUsersView
                    }
                }
                .padding(.top, 8)
            }
        }
        .edgesIgnoringSafeArea(.top)
    }
    
    var noUsersView: some View {
        VStack(alignment: .center) {
            Image("AppLogo")
                .frame(width: 68, height: 68)
                .padding([.top], 80)
            
            Spacer()
            
            Text("You have no additional contacts to request on Nevvi at this time.")
                .defaultStyle(size: 24)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .padding([.leading, .trailing])
            
            Spacer()
            
            OnboardingButton(text: "Next", action: self.primaryClick)
                .padding([.top, .leading, .trailing])
        }
    }
    
    var loadedUsersView: some View {
        VStack(alignment: .center, spacing: 12) {
            Image("AppLogo")
                .frame(width: 68, height: 68)
                .padding([.top], 80)
            
            HStack {
                Spacer()
                Text("Great! You have \(self.contactStore.contactsOnNevvi.count) \(self.contactStore.contactsOnNevvi.count == 1 ? "contact" : "contacts") already on Nevvi." )
                    .defaultStyle(size: 24)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .padding([.leading, .trailing])
                Spacer()
            }
            
            ScrollView(.vertical) {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(self.contactStore.contactsOnNevvi) { user in
                        return NewConnectionRequestRow(requestCallback: {
                            self.contactStore.removeContactOnNevvi(contact: user)
                        }, user: user)
                    }
                    .redacted(when: self.contactStore.loading, redactionType: .customPlaceholder)
                }
            }
            
            Spacer()
            
            OnboardingButton(text: "Next", action: self.primaryClick)
                .padding([.top, .leading, .trailing])
        }
    }
    
    func requestAccess() {
        self.contactStore.tryRequestAccess { result in
            switch(result){
            case .success(_):
                print("Got contact access!")
                self.contactStore.loadContacts()
                self.showContactPrompt = false
            case .failure(let error):
                print("Failed to get contact access because \(error.localizedDescription)")
                self.primaryClick()
            }
        }
    }
}

struct OnboardingContactsPrompt_Previews: PreviewProvider {
    static let modelData = ModelData()
    static let contactStore = ContactStore(
        contactsOnNevvi: modelData.usersResponse.users,
        contactsNotOnNevvi: [
            ContactStore.ContactInfo(firstName: "John", lastName: "Doe", phoneNumber: "6129631237"),
            ContactStore.ContactInfo(firstName: "Jane", lastName: "Doe", phoneNumber: "6129631237"),
        ]
    )
    
    static var previews: some View {
        OnboardingContactsPrompt(primaryClick: {})
            .environmentObject(contactStore)
    }
}
