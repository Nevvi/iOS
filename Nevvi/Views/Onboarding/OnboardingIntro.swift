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
        GeometryReader { geometry in
            VStack(spacing: 0) {
                ZStack {
                    VideoBackground(videoName: "nevvi_intro", videoExtension: "mp4")
                }
                .frame(width: geometry.size.width, height: geometry.size.height * 0.62) // anything more and text gets cutoff on SE
                .clipped()
                .ignoresSafeArea(.all, edges: .horizontal)
                
                ZStack(alignment: .bottom) {
                    VStack(spacing: 14) {
                        Text("Never ask for an address twice")
                            .defaultStyle(size: 30)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                            .padding([.leading, .trailing])
                        
                        Text("When a connection updates their address you will have instant access to the latest information.")
                            .defaultStyle(size: 14)
                            .multilineTextAlignment(.center)
                            .padding([.leading, .trailing], 32)
                        
                        Spacer()
                    }
                    
                    OnboardingButton(text: "Get Started", action: self.primaryClick)
                }
            }
        }
        .edgesIgnoringSafeArea(.top)
    }
}

struct OnboardingIntro_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingIntro(primaryClick: {
            
        })
    }
}
