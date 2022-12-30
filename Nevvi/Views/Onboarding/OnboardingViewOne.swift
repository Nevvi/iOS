//
//  OnboardingViewOne.swift
//  Nevvi
//
//  Created by Tyler Cobb on 12/30/22.
//

import SwiftUI

struct OnboardingViewOne: View {
    @State private var isAnimating: Bool = false
    
    var primaryClick: () -> Void

    var body: some View {
        VStack(spacing: 20.0) {
            Spacer()

            Text("Welcome to Nevvi!")
                .font(.title)
                .bold()
                .foregroundColor(.white)
            
            Spacer()

            Text("Our goal is to keep those in your life updated when those inevitable life changes happen.")
                .font(.headline)
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
                .shadow(color: Color.black.opacity(0.1), radius: 1, x: 2, y: 2)

            Spacer()
            Spacer()

            Button(action: self.primaryClick, label: {
                Text("Get Started")
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

struct OnboardingViewOne_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingViewOne(primaryClick: {
            
        })
    }
}
