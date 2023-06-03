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
    @State private var animateGroups = false
    @State private var animateDescription = false

    var body: some View {
        VStack(spacing: 20.0) {
            Text("Permission Groups")
                .onboardingTitle()
            
            Image(systemName: "lock")
                .font(.system(size: 80))
                .foregroundColor(.white)
                .padding([.top, .bottom], 30)
                            
            Text("Permission groups let you control what information of yours is seen by the person you connect with.")
                .onboardingStyle()
                .padding(10)
                .opacity(animateIntro ? 1.0 : 0.0)
                .onAppear {
                    withAnimation(Animation.spring().speed(0.2)) {
                        animateIntro = true
                    }
                }
                        
            Text("We've created 2 permission groups for you already:")
                .onboardingStyle()
                .padding([.leading, .trailing], 10)
                .opacity(animateGroups ? 1.0 : 0.0)
                .onAppear {
                    withAnimation(Animation.spring().speed(0.2).delay(2)) {
                        animateGroups = true
                    }
                }
            
            Text("**ALL**: All of your info\n**CONTACT_INFO**: Email and phone")
                .onboardingStyle()
                .fixedSize()
                .padding(10)
                .opacity(animateGroups ? 1.0 : 0.0)
            
            Text("You can configure more permission groups from your account page.")
                .onboardingStyle()
                .padding(10)
                .opacity(animateDescription ? 1.0 : 0.0)
                .onAppear {
                    withAnimation(Animation.spring().speed(0.2).delay(4)) {
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
