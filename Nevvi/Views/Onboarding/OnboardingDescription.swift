//
//  OnboardingViewFour.swift
//  Nevvi
//
//  Created by Tyler Cobb on 12/30/22.
//

import SwiftUI

struct OnboardingDescription: View {
    var primaryClick: () -> Void
    
    @State private var animateIntro = false
    @State private var animateDescription = false

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
                        Image("OnboardingDescriptionBackground")
                            .resizable()
                            .scaledToFit()
                        
                        Image("OnboardingDescription")
                          .foregroundColor(.clear)
                          .cornerRadius(24)
                          .shadow(color: Color(red: 0.06, green: 0.4, blue: 0.64).opacity(0.16), radius: 30, x: 0, y: 4)
                    }
                    
                    Text("Connect Easily")
                        .defaultStyle(size: 36, opacity: 1.0)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .padding([.top], -16)
                    
                    Text("Securely request and accept connections at the click of a button.")
                        .defaultStyle(size: 26, opacity: 0.7)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                }
                
                Spacer()
                                
                OnboardingButton(text: "Keep Going", action: self.primaryClick)
                    .padding([.bottom], 80)
                
            }
            .padding([.leading, .trailing])
        }
    }
}

struct OnboardingDescription_Previews: PreviewProvider {    
    static var previews: some View {
        OnboardingDescription(primaryClick: {})
    }
}
