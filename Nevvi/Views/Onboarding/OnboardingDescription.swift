//
//  OnboardingViewFour.swift
//  Nevvi
//
//  Created by Tyler Cobb on 12/30/22.
//

import SwiftUI

struct OnboardingDescription: View {
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
                
                Text("\"What's your address again?\"")
                    .defaultStyle(size: 26, opacity: 1.0)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .padding(.bottom)
                
                Text("How often are you asking for someone's address? With Nevvi, a connection lets both people securely view each other's information without asking each time.")
                    .defaultStyle(size: 20, opacity: 0.7)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding([.leading, .trailing])
                
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
