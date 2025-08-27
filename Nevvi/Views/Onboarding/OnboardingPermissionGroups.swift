//
//  OnboardingViewFour.swift
//  Nevvi
//
//  Created by Tyler Cobb on 12/30/22.
//

import SwiftUI

struct OnboardingPermissionGroups: View {
    var primaryClick: () -> Void
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                ZStack {
                    VideoBackground(videoName: "permission_groups_demo", videoExtension: "mp4")
                }
                .frame(height: geometry.size.height / 1.65)
                .clipped()
                .ignoresSafeArea(.all, edges: .horizontal)
                
                VStack(spacing: 10) {
                    Text("You control what you share")
                        .defaultStyle(size: 30)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .padding([.top, .leading, .trailing])
                    
                    Text("Your information stays private and secure - you control who sees what.")
                        .defaultStyle(size: 16)
                        .multilineTextAlignment(.center)
                        .padding([.leading, .trailing], 32)
                    
                    Spacer()
                    
                    OnboardingButton(text: "I'm interested", action: self.primaryClick)
                        .padding([.leading, .trailing])
                }
                .frame(height: geometry.size.height - (geometry.size.height / 1.65))
            }
        }
        .edgesIgnoringSafeArea(.top)
    }
}

struct OnboardingPermissionGroups_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingPermissionGroups(primaryClick: {})
    }
}
