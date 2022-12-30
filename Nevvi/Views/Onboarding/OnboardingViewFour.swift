//
//  OnboardingViewFour.swift
//  Nevvi
//
//  Created by Tyler Cobb on 12/30/22.
//

import SwiftUI

struct OnboardingViewFour: View {
    @State private var isAnimating: Bool = false
    @State private var firstName = ""
    @State private var lastName = ""
    
    @ObservedObject var accountStore: AccountStore
    
    var buttonDisabled: Bool {
        self.firstName.isEmpty || self.lastName.isEmpty
    }
    
    var primaryClick: () -> Void

    var body: some View {
        VStack(spacing: 20.0) {
            Spacer()
            
            Text("Thanks!")
                .font(.headline)
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
                .shadow(color: Color.black.opacity(0.1), radius: 1, x: 2, y: 2)
                .padding(30)
            
            
            Text("The heart and soul of this application is the connections you make with others.")
                .font(.headline)
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
                .shadow(color: Color.black.opacity(0.1), radius: 1, x: 2, y: 2)
                .padding(30)
            
            Text("Creating a connection creates a bi-directional link between 2 people where each person defines what they want the other person to have access to. Maybe they let you see everything, while you only want them to see your contact information and nothing else.")
                .font(.headline)
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
                .shadow(color: Color.black.opacity(0.1), radius: 1, x: 2, y: 2)
                .padding(30)
            
            Text("To specify only a subset of information to expose you'll need to create a custom permission group and select only the fields you want people in that group to see. Once you do that, when you request a connection or accept a connection you can select what group you want that user to be in.")
                .font(.headline)
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
                .shadow(color: Color.black.opacity(0.1), radius: 1, x: 2, y: 2)
                .padding(30)
            
            Spacer()
            
            Button(action: {
                self.accountStore.completeOnboarding { _ in
                    self.primaryClick()
                }
            }, label: {
                Text("Finish")
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
        .disabled(self.accountStore.saving)
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

struct OnboardingViewFour_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingViewFour(accountStore: AccountStore(), primaryClick: {})
    }
}
