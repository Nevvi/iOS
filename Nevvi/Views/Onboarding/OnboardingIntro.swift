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

                ZStack {
                    Image("OnboardingIntroBackground")
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 300)
                    
                    Image("OnboardingIntro")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.clear)
                        .cornerRadius(24)
                        .shadow(color: Color(red: 0.06, green: 0.4, blue: 0.64)
                        .opacity(0.16), radius: 30, x: 0, y: 4)
                        .frame(maxHeight: 250)
                }.padding()
                
                Text("Welcome to Nevvi")
                    .defaultStyle(size: 30, opacity: 1.0)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .padding(.bottom)
                
                Text("A Cloud-Based Contact Management Platform")
                    .defaultStyle(size: 20, opacity: 0.7)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding([.leading, .trailing])
                
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
