//
//  OnboardingViewOne.swift
//  Nevvi
//
//  Created by Tyler Cobb on 12/30/22.
//

import SwiftUI

struct OnboardingPrompt: View {
    @EnvironmentObject var accountStore: AccountStore
    
    @State var saving: Bool = false
    
    var primaryClick: () -> Void
    
    var isButtonDisabled: Bool {
        return self.accountStore.firstName.isEmpty || self.accountStore.lastName.isEmpty || self.saving
    }

    var body: some View {
        ZStack {
            Image("BackgroundBlur")
                .resizable()
                .aspectRatio(contentMode: .fill)
            
            VStack(alignment: .center) {
                Image("AppLogo")
                    .frame(width: 68, height: 68)
                    .padding([.top], 80)
                
                VStack(spacing: 24) {
                    Text("Almost done!")
                        .defaultStyle(size: 30, opacity: 1.0)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    
                    Text("How do you want to appear to others on Nevvi?")
                        .defaultStyle(size: 20, opacity: 0.7)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .padding(.bottom)
                        .padding([.leading, .trailing])
                    
                    VStack(spacing: 10) {
                        HStack {
                            Spacer()
                            ProfileImageSelector(height: 108, width: 108)
                            Spacer()
                        }
                        
                        TextField("First Name", text: self.$accountStore.firstName)
                            .onboardingStyle()
                        
                        TextField("Last Name", text: self.$accountStore.lastName)
                            .onboardingStyle()
                    }
                    .padding([.top, .leading, .trailing])
                }
                .padding(.top, 20)
                
                Spacer()
                Spacer()
                                
                OnboardingButton(text: "Finish", action: self.primaryAction)
                    .padding([.bottom], 80)
                    .disabled(self.isButtonDisabled)
                    .opacity(self.isButtonDisabled ? 0.5 : 1.0)
            }
            .padding([.leading, .trailing])
        }
    }
    
    func primaryAction() {
        self.saving = true
        self.accountStore.save { res in
            switch(res) {
            case .success(_):
                let request = AccountStore.PatchRequest(onboardingCompleted: true)
                self.accountStore.update(request: request) { _ in
                    self.primaryClick()
                    self.saving = false
                }
            case .failure(let err):
                print("Failed to complete onboarding", err)
                self.saving = false
            }
        }
    }
}

struct OnboardingPrompt_Previews: PreviewProvider {
    static let modelData = ModelData()
    static let accountStore = AccountStore(user: modelData.user)
    
    static var previews: some View {
        OnboardingPrompt(primaryClick: {})
        .environmentObject(accountStore)
    }
}
