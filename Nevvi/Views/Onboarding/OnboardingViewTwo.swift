//
//  OnboardingViewTwo.swift
//  Nevvi
//
//  Created by Tyler Cobb on 12/30/22.
//

import SwiftUI

struct OnboardingViewTwo: View {
    @State private var isAnimating: Bool = false
    
    var primaryClick: () -> Void

    var body: some View {
        VStack(spacing: 20.0) {
            Spacer()

            Text("How many times have you moved and had to let everyone in your life know your latest address to receive mail at? Have you ever gotten a new phone number and had to find a way to tell everyone what that new number is?")
                .font(.headline)
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
                .shadow(color: Color.black.opacity(0.1), radius: 1, x: 2, y: 2)
                .padding(30)
            
            
            Text("With Nevvi, instead of you having to update everyone with your latest information... we do it for you. Of course, you are still in control of your information and what you choose to share with each person specifically. What we want to solve is making sure you stay connected with those in your life even when stuff changes like an address or a phone number.")
                .font(.headline)
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
                .shadow(color: Color.black.opacity(0.1), radius: 1, x: 2, y: 2)
                .padding(30)
            
            Spacer()

            Button(action: self.primaryClick, label: {
                Text("Next")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 50)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .foregroundColor(Color(UIColor(hexString: "#49C5B6")))
                    )
            })
            .shadow(radius: 10)
        }
        .padding()
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(UIColor(hexString: "#33897F")),
                    Color(UIColor(hexString: "#5293B8"))
                ]),
                startPoint: .top,
                endPoint: .bottom)
            .edgesIgnoringSafeArea(.all))
        .onAppear(perform: {
            isAnimating = false
            withAnimation(.easeOut(duration: 0.5)) {
                self.isAnimating = true
            }
        })
    }
}

struct OnboardingViewTwo_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingViewTwo(primaryClick: {
            
        })
    }
}
