//
//  OnboardingViewFour.swift
//  Nevvi
//
//  Created by Tyler Cobb on 12/30/22.
//

import SwiftUI

struct OnboardingDescription: View {
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
            
            Text("Think of a connection like an entry in your contacts, but instead of you managing someone else's information, they manage it themselves.")
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

struct OnboardingDescription_Previews: PreviewProvider {    
    static var previews: some View {
        OnboardingDescription(primaryClick: {}, secondaryClick: {})
    }
}
