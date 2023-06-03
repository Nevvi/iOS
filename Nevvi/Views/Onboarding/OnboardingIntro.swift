//
//  OnboardingViewOne.swift
//  Nevvi
//
//  Created by Tyler Cobb on 12/30/22.
//

import SwiftUI

struct OnboardingIntro: View {    
    var primaryClick: () -> Void

    var body: some View {
        VStack(spacing: 20.0) {
            Spacer()
            Text("Welcome to Nevvi!")
                .onboardingTitle()
            
            Image("OnboardingOne")
                .resizable()
                .scaledToFit()
                .frame(width: 200)
                .padding([.top, .bottom], 50)
                        
            Text("We keep the personal information of all your contacts up to date, so you don't have to.")
                .onboardingStyle()
                .padding()

            Spacer()
            
            HStack {
                Spacer()
                primaryButton
            }
            .padding()

        }
        .padding([.leading, .trailing])
        .background(BackgroundGradient())
    }
    
    var primaryButton: some View {
        Button(action: self.primaryClick, label: {
            HStack {
                Text("Get Started")
                    .font(.headline)
                
                Image(systemName: "chevron.right")
            }
            .foregroundColor(ColorConstants.accent)
        })
    }
}

struct OnboardingIntro_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingIntro(primaryClick: {
            
        })
    }
}
