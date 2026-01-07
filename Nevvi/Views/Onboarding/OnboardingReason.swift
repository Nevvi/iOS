//
//  OnboardingViewOne.swift
//  Nevvi
//
//  Created by Tyler Cobb on 12/30/22.
//

import SwiftUI

struct OnboardingReason: View {
    @EnvironmentObject var connectionGroupsStore: ConnectionGroupsStore
    
    var primaryClick: () -> Void
    
    @State private var selectedReason: String? = nil
    @State private var showDetailView: Bool = false
    
    private let reasons = [
        "I'm getting married",
        "I'm sending holiday cards", 
        "Someone invited me",
        "I need someone's address",
        "Other"
    ]
    
    private var canContinue: Bool {
        return selectedReason != nil
    }

    var body: some View {
        if showDetailView, let selectedReason = selectedReason {
            reasonDetailView(for: selectedReason)
        } else {
            reasonSelectionView
        }
    }
    
    var reasonSelectionView: some View {
        GeometryReader { geometry in
            ZStack {
                Image("BackgroundBlur")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
                    .ignoresSafeArea(.all, edges: .horizontal)
            }
            
            ZStack(alignment: .bottom) {
                ScrollView {
                    VStack(alignment: .center, spacing: 12) {
                        Image("AppLogo")
                            .frame(width: 68, height: 68)
                            .padding([.top], geometry.size.height * 0.08)
                            .padding(.bottom)
                        
                        Text("What brings you to Nevvi?")
                            .defaultStyle(size: 30)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                        
                        Text("Help us tailor your experience")
                            .defaultStyle(size: 14)
                            .multilineTextAlignment(.center)
                            .padding(.bottom, 24)
                        
                        VStack(spacing: 12) {
                            ForEach(reasons, id: \.self) { reason in
                                Button(action: {
                                    selectedReason = reason
                                }) {
                                    HStack {
                                        Text(reason)
                                            .defaultStyle(size: 16)
                                            .foregroundColor(.black)
                                            .multilineTextAlignment(.leading)
                                        
                                        Spacer()
                                        
                                        Image(systemName: selectedReason == reason ? "checkmark.circle.fill" : "circle")
                                            .foregroundColor(selectedReason == reason ? ColorConstants.primary : Color.gray.opacity(0.3))
                                            .font(.system(size: 20))
                                    }
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.white)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(
                                                        selectedReason == reason ? ColorConstants.primary : Color.gray.opacity(0.3),
                                                        lineWidth: selectedReason == reason ? 2 : 1
                                                    )
                                            )
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 24)
                    }
                }
                
                OnboardingButton(text: "Continue", action: {
                    self.showDetailView = true
                })
                    .disabled(!canContinue)
                    .opacity(canContinue ? 1.0 : 0.5)
            }
        }
        .edgesIgnoringSafeArea(.top)
    }
    
    @ViewBuilder
    func reasonDetailView(for reason: String) -> some View {
        switch reason {
        case "I'm getting married":
            weddingDetailView
        case "I'm sending holiday cards":
            holidayCardsDetailView
        case "Someone invited me":
            invitedDetailView
        case "I need someone's address":
            needAddressDetailView
        case "Other":
            otherDetailView
        default:
            otherDetailView
        }
    }
    
    var weddingDetailView: some View {
        GeometryReader { geometry in
            ZStack {
                Image("BackgroundBlur")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
                    .ignoresSafeArea(.all, edges: .horizontal)
            }
            
            ZStack(alignment: .bottom) {
                ScrollView {
                    VStack(alignment: .center, spacing: 20) {
                        Image("AppLogo")
                            .frame(width: 68, height: 68)
                            .padding([.top], geometry.size.height * 0.08)
                            .padding(.bottom)
                        
                        Text("Perfect for weddings!")
                            .defaultStyle(size: 34)
                            .fontWeight(.semibold)
                            .multilineTextAlignment(.center)
                        
                        (Text("We've created a connection group called ")
                            .fontWeight(.light)
                        + Text("Wedding")
                            .fontWeight(.semibold)
                            .foregroundColor(ColorConstants.primary)
                        + Text(" to help you organize your guest list.")
                            .fontWeight(.light))
                            .defaultStyle(size: 17)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        VStack(alignment: .leading, spacing: 24) {
                            Text("Your next steps:")
                                .defaultStyle(size: 22)
                                .fontWeight(.semibold)
                                .padding(.top, 8)
                            
                            stepItem(number: 1, text: "Invite anyone going to the wedding without a Nevvi account to join (found on the ", highlightedText: "More", endText: " tab)")
                            
                            stepItem(number: 2, text: "Add anyone with a Nevvi account to the ", highlightedText: "Wedding", endText: " connection group")
                            
                            stepItem(number: 3, text: "Export the group information to CSV once all people have been added - this compiles everyone's most recent address into a single file for mailing")
                            
                            stepItem(number: 4, text: "Once you're wedding is done you'll continue to have access to up-to-date information in the app")
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 100) // Extra padding for floating button
                    }
                }
                
                OnboardingButton(text: "Continue") {
                    self.connectionGroupsStore.create(name: "Wedding") { (result: Result<ConnectionGroup, Error>) in
                        switch result {
                        case .success(_):
                            self.primaryClick()
                        case .failure(let error):
                            print("Something bad happened", error)
                            self.primaryClick()
                        }
                    }
                }
                .disabled(self.connectionGroupsStore.creating)
                .opacity(self.connectionGroupsStore.creating ? 0.5 : 1.0)
            }
            .padding(.horizontal)
        }
        .edgesIgnoringSafeArea(.top)
    }
    
    var holidayCardsDetailView: some View {
        GeometryReader { geometry in
            ZStack {
                Image("BackgroundBlur")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
                    .ignoresSafeArea(.all, edges: .horizontal)
            }
            
            ZStack(alignment: .bottom) {
                ScrollView {
                    VStack(alignment: .center, spacing: 20) {
                        Image("AppLogo")
                            .frame(width: 68, height: 68)
                            .padding([.top], geometry.size.height * 0.08)
                            .padding(.bottom)
                        
                        Text("Perfect for holiday cards!")
                            .defaultStyle(size: 34)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                        
                        (Text("We've created a connection group called ")
                            .fontWeight(.light)
                        + Text("Holiday Cards")
                            .fontWeight(.semibold)
                            .foregroundColor(ColorConstants.primary)
                        + Text(" to help you organize your mailing list.")
                            .fontWeight(.light))
                            .defaultStyle(size: 17)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        VStack(alignment: .leading, spacing: 24) {
                            Text("Your next steps:")
                                .defaultStyle(size: 22)
                                .fontWeight(.semibold)
                                .padding(.top, 8)
                            
                            stepItem(number: 1, text: "Invite anyone you want to send cards to without a Nevvi account to join (found on the ", highlightedText: "More", endText: " tab)")
                            
                            stepItem(number: 2, text: "Add anyone with a Nevvi account to the ", highlightedText: "Holiday Cards", endText: " connection group")
                            
                            stepItem(number: 3, text: "Export the group information once all people have been added - this compiles everyone's most recent address into a single file for mailing")
                            
                            stepItem(number: 4, text: "Once you've sent your cards in the mail you'll continue to have access to up-to-date information in the app")
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 100) // Extra padding for floating button
                    }
                }
                
                OnboardingButton(text: "Continue") {
                    self.connectionGroupsStore.create(name: "Holiday Cards") { (result: Result<ConnectionGroup, Error>) in
                        switch result {
                        case .success(_):
                            self.primaryClick()
                        case .failure(let error):
                            print("Something bad happened", error)
                            self.primaryClick()
                        }
                    }
                }
                .disabled(self.connectionGroupsStore.creating)
                .opacity(self.connectionGroupsStore.creating ? 0.5 : 1.0)
            }
        }
        .edgesIgnoringSafeArea(.top)
    }
    
    var invitedDetailView: some View {
        GeometryReader { geometry in
            ZStack {
                Image("BackgroundBlur")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
                    .ignoresSafeArea(.all, edges: .horizontal)
            }
            
            ZStack(alignment: .bottom) {
                ScrollView {
                    VStack(alignment: .center, spacing: 20) {
                        Image("AppLogo")
                            .frame(width: 68, height: 68)
                            .padding([.top], geometry.size.height * 0.08)
                            .padding(.bottom)
                        
                        Text("Welcome to Nevvi!")
                            .defaultStyle(size: 34)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                        
                        Text("Someone invited you to connect and share information securely.")
                            .defaultStyle(size: 17)
                            .fontWeight(.light)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        VStack(alignment: .leading, spacing: 24) {
                            Text("Your next steps:")
                                .defaultStyle(size: 22)
                                .fontWeight(.semibold)
                                .padding(.top, 8)
                            
                            stepItem(number: 1, text: "Fill out your profile with your information")
                            
                            stepItem(number: 2, text: "Complete onboarding to see your outstanding connection request on the ", highlightedText: "Connections", endText: " tab")
                            
                            stepItem(number: 3, text: "Accept the request from the person who invited you to start sharing information securely")
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 100) // Extra padding for floating button
                    }
                }
                
                OnboardingButton(text: "Continue", action: self.primaryClick)
            }
        }
        .edgesIgnoringSafeArea(.top)
    }
    
    var needAddressDetailView: some View {
        GeometryReader { geometry in
            ZStack {
                Image("BackgroundBlur")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
                    .ignoresSafeArea(.all, edges: .horizontal)
            }
            
            ZStack(alignment: .bottom) {
                ScrollView {
                    VStack(alignment: .center, spacing: 20) {
                        Image("AppLogo")
                            .frame(width: 68, height: 68)
                            .padding([.top], geometry.size.height * 0.08)
                            .padding(.bottom)
                        
                        Text("Let's find that address!")
                            .defaultStyle(size: 34)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                        
                        Text("Nevvi makes it easy to connect with people and get their latest information.")
                            .defaultStyle(size: 17)
                            .fontWeight(.light)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        VStack(alignment: .leading, spacing: 24) {
                            Text("Your next steps:")
                                .defaultStyle(size: 22)
                                .fontWeight(.semibold)
                                .padding(.top, 8)
                            
                            stepItem(number: 1, text: "Fill out your profile with your information")
                            
                            stepItem(number: 2, text: "If the person has an account, search for them on the ", highlightedText: "Connections", endText: " tab")
                            
                            stepItem(number: 3, text: "If they don't have an account yet, invite them using the ", highlightedText: "Invite Users", endText: " feature in the ", highlightedText2: "More", endText2: " tab")
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 100) // Extra padding for floating button
                    }
                }
                
                OnboardingButton(text: "Continue", action: self.primaryClick)
            }
        }
        .edgesIgnoringSafeArea(.top)
    }
    
    var otherDetailView: some View {
        GeometryReader { geometry in
            ZStack {
                Image("BackgroundBlur")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
                    .ignoresSafeArea(.all, edges: .horizontal)
            }
            
            ZStack(alignment: .bottom) {
                ScrollView {
                    VStack(alignment: .center, spacing: 20) {
                        Image("AppLogo")
                            .frame(width: 68, height: 68)
                            .padding([.top], geometry.size.height * 0.08)
                            .padding(.bottom)
                        
                        Text("Welcome to Nevvi!")
                            .defaultStyle(size: 34)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                        
                        Text("Securely share and receive up-to-date information with trusted connections.")
                            .defaultStyle(size: 17)
                            .fontWeight(.light)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        VStack(alignment: .leading, spacing: 24) {
                            Text("Key features:")
                                .defaultStyle(size: 22)
                                .fontWeight(.semibold)
                                .padding(.top, 8)
                            
                            featureItem(icon: "person.2.fill", title: "Connection Groups", description: "Organize your contacts into groups for easy management and sharing")
                            
                            featureItem(icon: "shield.checkerboard", title: "Secure Sharing", description: "Control who sees what information with granular privacy controls")
                            
                            featureItem(icon: "arrow.triangle.2.circlepath", title: "Always Up-to-Date", description: "Automatically receive the latest information when your connections update their details")
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 100) // Extra padding for floating button
                    }
                }
                
                OnboardingButton(text: "Continue", action: self.primaryClick)
            }
        }
        .edgesIgnoringSafeArea(.top)
    }
    
    func stepItem(number: Int, text: String, highlightedText: String? = nil, endText: String? = nil, highlightedText2: String? = nil, endText2: String? = nil) -> some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle()
                    .fill(ColorConstants.primary)
                    .frame(width: 26, height: 26)
                
                Text("\(number)")
                    .font(.system(size: 13, weight: .heavy))
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                if let highlightedText = highlightedText {
                    let fullText = (Text(text)
                        .fontWeight(.light)
                    + Text(highlightedText)
                        .fontWeight(.semibold)
                        .foregroundColor(ColorConstants.primary)
                    + Text(endText ?? "")
                        .fontWeight(.light)
                    + (highlightedText2 != nil ?
                        Text(highlightedText2!)
                        .fontWeight(.semibold)
                            .foregroundColor(ColorConstants.primary)
                        : Text(""))
                    + Text(endText2 ?? "")
                        .fontWeight(.light))
                    
                    fullText
                        .defaultStyle(size: 17, opacity: 1.0, weight: .light)
                        .multilineTextAlignment(.leading)
                        .lineLimit(nil)
                } else {
                    Text(text)
                        .defaultStyle(size: 17, opacity: 1.0, weight: .light)
                        .multilineTextAlignment(.leading)
                        .lineLimit(nil)
                }
            }
            
            Spacer()
        }
    }
    
    func featureItem(icon: String, title: String, description: String) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 22, weight: .semibold))
                .foregroundColor(ColorConstants.primary)
                .frame(width: 26)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .defaultStyle(size: 17)
                    .fontWeight(.semibold)
                
                Text(description)
                    .defaultStyle(size: 15)
                    .fontWeight(.light)
                    .multilineTextAlignment(.leading)
                    .lineLimit(nil)
            }
            
            Spacer()
        }
    }
}

struct OnboardingReason_Previews: PreviewProvider {
    static let connectionGroupsStore = ConnectionGroupsStore(groups: [])
    
    static var previews: some View {
        OnboardingReason(primaryClick: {
            print("Continue tapped")
        })
        .environmentObject(connectionGroupsStore)
    }
}
