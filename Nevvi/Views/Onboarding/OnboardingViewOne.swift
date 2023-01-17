//
//  OnboardingViewOne.swift
//  Nevvi
//
//  Created by Tyler Cobb on 12/30/22.
//

import SwiftUI

struct OnboardingViewOne: View {    
    var primaryClick: () -> Void

    var body: some View {
        VStack() {
            Spacer()

            Text("Welcome to Nevvi!")
                .font(.title)
                .bold()
                .foregroundColor(.white)
                .padding(20)
            
            Image("ConnectionGrid")
                .resizable()
                .scaledToFit()
                .padding()
                        
            Text("We keep all your connections up to date, so you don't have to.")
                .onboardingStyle()
                .padding(20)

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
            .foregroundColor(.white)
        })
    }
}

struct OnboardingViewOne_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingViewOne(primaryClick: {
            
        })
    }
}
