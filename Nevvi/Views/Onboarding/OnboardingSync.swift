//
//  OnboardingViewThree.swift
//  Nevvi
//
//  Created by Tyler Cobb on 12/30/22.
//

import SwiftUI

struct OnboardingSync: View {
    var primaryClick: () -> Void
    
    @EnvironmentObject var accountStore: AccountStore
    
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
                    .padding([.top], 64)

                VStack(alignment: .center, spacing: 12) {
                    ZStack {
                        Image("OnboardingSyncBackground")
                            .resizable()
                            .scaledToFit()
                        
                        Image("OnboardingSync")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.clear)
                            .background(.clear)
                            .cornerRadius(24)
                            .shadow(color: Color(red: 0.06, green: 0.4, blue: 0.64).opacity(0.16), radius: 30, x: 0, y: 4)
                    }
                    .frame(maxHeight: 350)
                    
                    Text("Get Updated Information")
                        .defaultStyle(size: 30, opacity: 1.0)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .padding([.top], -16)
                    
                    Text("We'll notify you when a connection updates their info.")
                        .defaultStyle(size: 22, opacity: 0.7)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                }
                
                Spacer()
                                
                OnboardingButton(text: "Finish", action: self.primaryAction)
                    .padding([.bottom], 80)
                
            }
            .padding([.leading, .trailing])
        }
    }
    
    func primaryAction() {
        let request = AccountStore.PatchRequest(onboardingCompleted: true)
        self.accountStore.update(request: request) { _ in
            self.primaryClick()
        }
    }
}

struct OnboardingSync_Previews: PreviewProvider {
    static let modelData = ModelData()
    static let accountStore = AccountStore(user: modelData.user)
    
    static var previews: some View {
        OnboardingSync(primaryClick: {})
            .environmentObject(accountStore)
    }
}
