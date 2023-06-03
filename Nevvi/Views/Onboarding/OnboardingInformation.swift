//
//  OnboardingViewTwo.swift
//  Nevvi
//
//  Created by Tyler Cobb on 12/30/22.
//

import SwiftUI

struct OnboardingInformation: View {
    @State private var firstName = ""
    @State private var lastName = ""
    
    @EnvironmentObject var accountStore: AccountStore
    
    var buttonDisabled: Bool {
        self.firstName.isEmpty || self.lastName.isEmpty
    }
    
    var primaryClick: () -> Void
    var secondaryClick: () -> Void

    var body: some View {
        VStack {
            Text("Nevvi").onboardingTitle()
            
            Text("Let's get some more information so that others can find you.")
                .onboardingStyle()
                .padding(30)
            
            ProfileImageSelector(height: 120, width: 120)
            
            VStack(alignment: .leading, spacing: 15) {
            TextField("First Name", text: self.$firstName)
                .padding()
                .background(ColorConstants.accent)
                .foregroundColor(ColorConstants.text)
                .cornerRadius(20.0)
                .submitLabel(.done)
                .disableAutocorrection(true)
                
            TextField("Last Name", text: self.$lastName)
                .padding()
                .background(ColorConstants.accent)
                .foregroundColor(ColorConstants.text)
                .cornerRadius(20.0)
                .submitLabel(.done)
                .disableAutocorrection(true)
                
            }.padding([.leading, .trailing, .top])
            
            Spacer()
            
            HStack {
                secondaryButton
                
                Spacer()
                
                primaryButton
            }
            .padding()
        }
        .disabled(self.accountStore.saving)
        .padding()
        .background(BackgroundGradient())
        .preferredColorScheme(.light)
    }
    
    var primaryButton: some View {
        Button(action: self.primaryAction, label: {
            if !self.buttonDisabled {
                HStack {
                    Text("Next")
                        .font(.headline)
                    
                    Image(systemName: "chevron.right")
                }
                .foregroundColor(ColorConstants.accent)
                .opacity(self.accountStore.saving ? 0.5 : 1.0)
            }
        })
        .disabled(self.accountStore.saving)
    }
    
    var secondaryButton: some View {
        Button(action: self.secondaryClick, label: {
            HStack {
                Image(systemName: "chevron.left")
                
                Text("Back")
                    .font(.headline)
            }
            .foregroundColor(ColorConstants.accent)
            .opacity(self.accountStore.saving ? 0.5 : 1.0)
        })
    }
    
    func primaryAction() {
        let request = AccountStore.PatchRequest(firstName: firstName, lastName: lastName)
        self.accountStore.update(request: request) { _ in
            self.primaryClick()
        }
    }
}

struct OnboardingInformation_Previews: PreviewProvider {
    static let modelData = ModelData()
    static let accountStore = AccountStore(user: modelData.user)
    
    static var previews: some View {
        OnboardingInformation(primaryClick: {}, secondaryClick: {})
            .environmentObject(accountStore)
    }
}
