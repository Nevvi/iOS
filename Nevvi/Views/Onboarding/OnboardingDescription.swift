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

                ZStack {
                    Image("OnboardingDescriptionBackground")
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 300)
                    
                    Image("OnboardingDescription")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.clear)
                        .cornerRadius(24)
                        .shadow(color: Color(red: 0.06, green: 0.4, blue: 0.64).opacity(0.16), radius: 30, x: 0, y: 4)
                        .frame(maxHeight: 250)
                }.padding()
                
                Text("Create Connections")
                    .defaultStyle(size: 30, opacity: 1.0)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .padding(.bottom)
                
                Text("Securely request and accept connections at the click of a button.")
                    .defaultStyle(size: 20, opacity: 0.7)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                
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
