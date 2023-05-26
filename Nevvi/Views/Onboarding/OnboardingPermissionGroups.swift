//
//  OnboardingPermissionGroups.swift
//  Nevvi
//
//  Created by Tyler Standal on 5/25/23.
//

import SwiftUI

struct OnboardingPermissionGroups: View {
    var primaryClick: () -> Void
    var secondaryClick: () -> Void
    
    @State private var animateIntro = false
    @State private var animateDescription = false

    var body: some View {
        VStack(spacing: 20.0) {
            Text("Nevvi")
                .onboardingTitle()
            
            VStack {
                Image(systemName: "lock")
                    .font(.system(size: 100))
                Text("Permission Groups")
                    .onboardingTitle()
            }
            .foregroundColor(.white)
            .padding([.top, .bottom], 60)
                        
            Text("Permission groups let you control what information of yours is seen by others.")
                .onboardingStyle()
                .padding(10)
                .opacity(animateIntro ? 1.0 : 0.0)
                .onAppear {
                    withAnimation(Animation.spring().speed(0.2)) {
                        animateIntro = true
                    }
                }
            
            Text("You can configure your permission groups from your account page.")
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

struct OnboardingPermissionGroups_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingPermissionGroups(primaryClick: {}, secondaryClick: {})
    }
}
