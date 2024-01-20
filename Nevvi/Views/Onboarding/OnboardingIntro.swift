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
        ZStack {
            Image("BackgroundBlur")
                .resizable()
                .aspectRatio(contentMode: .fill)
            
            VStack(alignment: .center) {
                Image("AppLogo")
                    .frame(width: 68, height: 68)
                    .padding([.top], 80)

                VStack(alignment: .center, spacing: 6) {
                    ZStack {
                        Image("OnboardingIntroBackground")
                            .resizable()
                            .scaledToFit()
                        
                        Image("OnboardingIntro")
                          .foregroundColor(.clear)
                          .cornerRadius(24)
                          .shadow(color: Color(red: 0.06, green: 0.4, blue: 0.64).opacity(0.16), radius: 30, x: 0, y: 4)
                    }
                    
                    Text("Cloud-Based")
                        .defaultStyle(size: 36, opacity: 1.0)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    
                    Text("Contact Management Platform")
                        .defaultStyle(size: 26, opacity: 0.7)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                }.padding([.top], 32)
                
                Spacer()
                                
                OnboardingButton(text: "Let's Start", action: self.primaryClick)
                    .padding([.bottom], 80)
            }
            .padding([.leading, .trailing])
        }
    }
}

struct OnboardingIntro_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingIntro(primaryClick: {
            
        })
    }
}
