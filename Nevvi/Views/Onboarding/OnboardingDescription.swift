//
//  OnboardingViewFour.swift
//  Nevvi
//
//  Created by Tyler Cobb on 12/30/22.
//

import SwiftUI

struct OnboardingDescription: View {
    @State private var firstName = ""
    @State private var lastName = ""
    
    @EnvironmentObject var accountStore: AccountStore
    
    var buttonDisabled: Bool {
        self.firstName.isEmpty || self.lastName.isEmpty
    }
    
    var primaryClick: () -> Void
    var secondaryClick: () -> Void

    var body: some View {
        VStack(spacing: 20.0) {
            Text("Nevvi")
                .onboardingTitle()
            
            Spacer()
            Image("OnboardingThree")
            Spacer()
            
            Text("The heart and soul of Nevvi is the connections you make with others.")
                .onboardingStyle()
                .padding(10)
            
            Text("Think of a connection like an entry in your contacts, but instead of you managing someone else's information they manage it themselves.")
                .onboardingStyle()
                .padding(10)
            
            Spacer()
            
            HStack {
                secondaryButton
                
                Spacer()
               
                primaryButton
            }
            .padding([.leading, .trailing])
            
        }
        .disabled(self.accountStore.saving)
        .padding()
        .background(BackgroundGradient())
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
        .foregroundColor(ColorConstants.accent)
    }
    
    var secondaryButton: some View {
        Button(action: self.secondaryClick, label: {
            HStack {
                Image(systemName: "chevron.left")
                
                Text("Back")
                    .font(.headline)
                    .foregroundColor(ColorConstants.accent)
            }
            .foregroundColor(ColorConstants.accent)
            .opacity(self.accountStore.saving ? 0.5 : 1.0)
        })
    }
    
    func primaryAction() {
        self.accountStore.completeOnboarding { _ in
            self.primaryClick()
        }
    }
}

struct OnboardingDescription_Previews: PreviewProvider {
    static let modelData = ModelData()
    static let accountStore = AccountStore(user: modelData.user)
    
    static var previews: some View {
        OnboardingDescription(primaryClick: {}, secondaryClick: {})
            .environmentObject(accountStore)
    }
}
