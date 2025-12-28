//
//  OnboardingViewOne.swift
//  Nevvi
//
//  Created by Tyler Cobb on 12/30/22.
//

import SwiftUI

struct OnboardingSuccess: View {
    @EnvironmentObject var accountStore: AccountStore
    @EnvironmentObject var connectionsStore: ConnectionsStore
    @State var saving: Bool = false
    
    var primaryClick: () -> Void

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Image("BackgroundBlur")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
                    .ignoresSafeArea(.all, edges: .horizontal)
            }
            
            VStack(alignment: .center, spacing: 64) {
                Spacer()
                Image("OnboardingSuccess")
                    .frame(width: 68, height: 68)
                    .padding([.top], 80)
                
                Text("You're all set up!")
                    .defaultStyle(size: 30, opacity: 1.0)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .padding([.top], 32)
                
                Spacer()
                                
                OnboardingButton(text: "Explore the app", action: self.primaryAction)
                    .disabled(self.saving)
                    .opacity(self.saving ? 0.5 : 1.0)
            }
            .padding([.leading, .trailing])
        }
        .edgesIgnoringSafeArea([.top])
    }
    
    func primaryAction() {
        self.saving = true
        let request = AccountStore.PatchRequest(onboardingCompleted: true)
        self.accountStore.update(request: request) { _ in
            // Connections and requests could've changed during onboarding so fetch them before going into the app
            DispatchQueue.main.async {
                self.connectionsStore.load()
                self.connectionsStore.loadRequests()
                self.primaryClick()
                self.saving = false
            }
        }
    }
}

struct OnboardingSuccess_Previews: PreviewProvider {
    static let modelData = ModelData()
    static let accountStore = AccountStore(user: modelData.user)
    static let connectionsStore = ConnectionsStore(connections: [],
                                                   requests: [],
                                                   blockedUsers: [])
    
    static var previews: some View {
        OnboardingSuccess(primaryClick: {})
            .environmentObject(accountStore)
            .environmentObject(connectionsStore)
    }
}
