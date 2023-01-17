//
//  OnboardingViewTwo.swift
//  Nevvi
//
//  Created by Tyler Cobb on 12/30/22.
//

import SwiftUI

struct OnboardingViewTwo: View {
    @State private var firstName = ""
    @State private var lastName = ""
    
    @EnvironmentObject var accountStore: AccountStore
    
    var buttonDisabled: Bool {
        self.firstName.isEmpty || self.lastName.isEmpty
    }
    
    var primaryClick: () -> Void
    var secondaryClick: () -> Void

    var body: some View {
        VStack(spacing: 20.0) {
            Text("Nevvi")
                .font(.title)
                .bold()
                .foregroundColor(.white)
                .padding()
            
            Text("Let's get some more information so that others can find you.")
                .onboardingStyle()
                .padding(30)
            
            ProfileImageSelector(height: 120, width: 120)
            
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
            
            HStack {
                secondaryButton
                
                Spacer()
                
                primaryButton
            }
            .padding([.leading, .trailing])
        }
        .disabled(self.accountStore.saving)
        .padding()
        .background(BackgroundGradient())
    }
    
    var primaryButton: some View {
        Button(action: self.primaryAction, label: {
            if !self.buttonDisabled {
                HStack {
                    Text("Next")
                        .font(.headline)
                    
                    Image(systemName: "chevron.right")
                }
                .foregroundColor(self.accountStore.saving ? .accentColor : .white)
            }
        })
    }
    
    var secondaryButton: some View {
        Button(action: self.secondaryClick, label: {
            HStack {
                Image(systemName: "chevron.left")
                
                Text("Back")
                    .font(.headline)
            }
            .foregroundColor(.white)
        })
    }
    
    func primaryAction() {
        let request = AccountStore.PatchRequest(firstName: firstName, lastName: lastName)
        self.accountStore.update(request: request) { _ in
            self.primaryClick()
        }
    }
}

struct OnboardingViewTwo_Previews: PreviewProvider {
    static let modelData = ModelData()
    static let accountStore = AccountStore(user: modelData.user)
    
    static var previews: some View {
        OnboardingViewTwo(primaryClick: {}, secondaryClick: {})
            .environmentObject(accountStore)
    }
}
