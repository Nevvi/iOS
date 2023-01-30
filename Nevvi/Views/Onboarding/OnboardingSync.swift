//
//  OnboardingViewThree.swift
//  Nevvi
//
//  Created by Tyler Cobb on 12/30/22.
//

import SwiftUI

struct OnboardingSync: View {
    var primaryClick: () -> Void
    var secondaryClick: () -> Void
    
    @EnvironmentObject var accountStore: AccountStore
    
    @State var enabledSync: Bool = true

    var body: some View {
        VStack(spacing: 20.0) {
            Text("Nevvi")
                .onboardingTitle()
            
            Spacer()
            Image("OnboardingTwo")
            Spacer()
            
            Text("\"Do you still live at ...?\"")
                .onboardingTitle()
                .padding([.bottom], 20)
            
            Text("With Nevvi, as long as you are connected with a person we can keep your device synced when their data, such as address, changes.")
                .onboardingStyle()
                .padding([.leading, .trailing, .bottom], 20)
            
            Toggle("Keep my device synced", isOn: self.$enabledSync)
                .foregroundColor(ColorConstants.accent)
                .toggleStyle(.switch)
                .padding([.leading, .trailing], 30)
            
            Spacer()
            Spacer()
            
            HStack {
                secondaryButton
                Spacer()
                primaryButton
            }
            .padding([.leading, .trailing])
        }
        .padding()
        .background(BackgroundGradient())
    }
    
    var primaryButton: some View {
        Button(action: self.primaryAction, label: {
            HStack {
                Text("Next")
                    .font(.headline)
                
                Image(systemName: "chevron.right")
            }
            .foregroundColor(ColorConstants.accent)
            .opacity(self.accountStore.saving ? 0.5 : 1.0)
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
        })
    }
    
    func primaryAction() {
        let request = AccountStore.PatchRequest(deviceSettings: DeviceSettings(autoSync: self.enabledSync, syncAllInformation: false))
        self.accountStore.update(request: request) { _ in
            self.primaryClick()
        }
    }
}

struct OnboardingSync_Previews: PreviewProvider {
    static let modelData = ModelData()
    static let accountStore = AccountStore(user: modelData.user)
    
    static var previews: some View {
        OnboardingSync(primaryClick: {}, secondaryClick: {})
            .environmentObject(accountStore)
    }
}
