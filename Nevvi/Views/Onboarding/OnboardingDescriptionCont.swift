//
//  OnboardingDescriptionCont.swift
//  Nevvi
//
//  Created by Tyler Cobb on 2/4/23.
//

import SwiftUI

struct OnboardingDescriptionCont: View {    
    var primaryClick: () -> Void
    var secondaryClick: () -> Void
    
    @State private var animateIntro = false
    @State private var animateDescription = false

    var body: some View {
        VStack(spacing: 20.0) {
            Text("Nevvi")
                .onboardingTitle()
            
            Spacer()
            Image("OnboardingFour")
            Spacer()
            
            Text("In other words...")
                .onboardingStyle()
                .padding(10)
                .opacity(animateIntro ? 1.0 : 0.0)
                .onAppear {
                    withAnimation(Animation.spring().speed(0.2)) {
                        animateIntro = true
                    }
                }
            
            Text("Anytime you update your data it will automatically be sent to the connections that are allowed to see it.")
                .onboardingStyle()
                .padding(10)
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
        })
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
        })
    }
}

struct OnboardingDescriptionCont_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingDescriptionCont(primaryClick: {}, secondaryClick: {})
    }
}
