//
//  OnboardingViewThree.swift
//  Nevvi
//
//  Created by Tyler Cobb on 12/30/22.
//

import SwiftUI

struct OnboardingViewThree: View {
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

            Text("First things first let's get some more information about you so that others can find you.")
                .font(.headline)
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
                .shadow(color: Color.black.opacity(0.1), radius: 1, x: 2, y: 2)
                .padding(30)
            
            VStack(alignment: .leading, spacing: 15) {
                TextField("First Name", text: self.$firstName)
                    .padding()
                    .background(.white)
                    .cornerRadius(20.0)
                
                TextField("Last Name", text: self.$lastName)
                    .padding()
                    .background(.white)
                    .cornerRadius(20.0)
            }.padding(27.5)
            
            Spacer()

            Button(action: {
                let request = AccountStore.PatchRequest(firstName: firstName, lastName: lastName)
                self.accountStore.update(request: request) { _ in
                    self.primaryClick()
                }
            }, label: {
                Text("Update")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 50)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .foregroundColor(self.buttonDisabled ? .gray : Color(UIColor(hexString: "#49C5B6")))
                    )
            })
            .shadow(radius: 10)
            .disabled(buttonDisabled)
            
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

struct OnboardingViewThree_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingViewThree(accountStore: AccountStore(), primaryClick: {})
    }
}
