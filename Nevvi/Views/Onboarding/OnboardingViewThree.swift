//
//  OnboardingViewThree.swift
//  Nevvi
//
//  Created by Tyler Cobb on 12/30/22.
//

import SwiftUI

struct OnboardingViewThree: View {
    var primaryClick: () -> Void
    var secondaryClick: () -> Void
    
    @State var enabledSync: Bool = true

    var body: some View {
        VStack(spacing: 20.0) {
            Text("Do you still live at ...?")
                .font(.title)
                .bold()
                .foregroundColor(.white)
                .padding()
            
            Text("With Nevvi, as long as you are connected with a person we can keep your device synced when their data, such as address, changes.")
                .onboardingStyle()
                .padding(20)
            
            Toggle("Keep my device synced", isOn: self.$enabledSync)
                .foregroundColor(.white)
                .toggleStyle(.switch)
                .padding(30)
            
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
        Button(action: self.primaryClick, label: {
            HStack {
                Text("Next")
                    .font(.headline)
                
                Image(systemName: "chevron.right")
            }
            .foregroundColor(.white)
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
}

struct OnboardingViewThree_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingViewThree(primaryClick: {}, secondaryClick: {})
    }
}
