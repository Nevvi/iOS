//
//  OnboardingViewThree.swift
//  Nevvi
//
//  Created by Tyler Cobb on 12/30/22.
//

import SwiftUI

struct OnboardingSync: View {
    var primaryClick: () -> Void
    var secondaryClick: () -> Void
    
    @EnvironmentObject var accountStore: AccountStore
    
    @State private var animateIntro = false
    @State private var animateDescription = false

    var body: some View {
        VStack(spacing: 20.0) {
            Text("\"Do you still live at ...?\"")
                .onboardingTitle()
            Spacer()
            
            Image("OnboardingTwo")
                .resizable()
                .scaledToFit()
                .frame(width: 200)
            Spacer()
            
            Text("With Nevvi, as long as you stay connected with a person we can keep the contact in your phone in sync when their data, such as address, changes.")
                .onboardingStyle()
                .padding([.leading, .trailing, .bottom], 20)
                .opacity(animateIntro ? 1.0 : 0.0)
                .onAppear {
                    withAnimation(Animation.spring().speed(0.2)) {
                        animateIntro = true
                    }
                }
                        
            Text("Let's find some people you may know to connect with...")
                .onboardingStyle()
                .padding([.leading, .trailing, .bottom], 20)
                .opacity(animateDescription ? 1.0 : 0.0)
                .onAppear {
                    withAnimation(Animation.spring().speed(0.2).delay(2)) {
                        animateDescription = true
                    }
                }
            
            Spacer()
            
            HStack {
                secondaryButton
                Spacer()
                primaryButton
            }
            .padding([.leading, .trailing])
        }
        .padding()
        .background(BackgroundGradient())
    }
    
    var primaryButton: some View {
        Button(action: self.primaryClick, label: {
            HStack {
                Text("Next")
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
}

struct OnboardingSync_Previews: PreviewProvider {
    static let modelData = ModelData()
    static let accountStore = AccountStore(user: modelData.user)
    
    static var previews: some View {
        OnboardingSync(primaryClick: {}, secondaryClick: {})
            .environmentObject(accountStore)
    }
}
