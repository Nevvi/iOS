//
//  OnboardingViewFour.swift
//  Nevvi
//
//  Created by Tyler Cobb on 12/30/22.
//

import SwiftUI

struct OnboardingConnectionGroups: View {
    var primaryClick: () -> Void
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                ZStack {
                    VideoBackground(videoName: "connection_groups_demo", videoExtension: "mp4")
                }
                .frame(width: geometry.size.width, height: geometry.size.height * 0.63)
                .clipped()
                .ignoresSafeArea(.all, edges: .horizontal)
                .padding(.bottom)
                
                ZStack(alignment: .bottom) {
                    VStack(spacing: 10) {
                        Text("Create groups for different occasions")
                            .defaultStyle(size: 30)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                            .padding([.leading, .trailing])
                        
                        Text("Planning a wedding or sending holiday cards? Get everyone's current info in one click.")
                            .defaultStyle(size: 14)
                            .multilineTextAlignment(.center)
                            .padding([.leading, .trailing], 32)
                        
                        Spacer()
                    }
                    
                    OnboardingButton(text: "Let's set this up", action: self.primaryClick)
                }
            }
        }
        .edgesIgnoringSafeArea(.top)
    }
}

struct OnboardingConnectionGroups_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingConnectionGroups(primaryClick: {})
    }
}
