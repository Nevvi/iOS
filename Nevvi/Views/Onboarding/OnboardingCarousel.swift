//
//  Onboarding.swift
//  Nevvi
//
//  Created by Tyler Cobb on 12/30/22.
//

import SwiftUI

struct OnboardingCarousel: View {
    @State var index = 0
    @ObservedObject var accountStore: AccountStore
    
    var body: some View {
        VStack{
            TabView(selection: $index) {
                OnboardingViewOne(primaryClick: {
                    self.index = 1
                }).tag(0)
                OnboardingViewTwo(primaryClick: {
                    self.index = 2
                }).tag(1)
                OnboardingViewThree(accountStore: self.accountStore, primaryClick: {
                    self.index = 3
                }).tag(2)
                OnboardingViewFour(accountStore: self.accountStore, primaryClick: {
                    
                }).tag(3)
            }
        }.ignoresSafeArea()
    }
}

struct Onboarding_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingCarousel(accountStore: AccountStore())
    }
}
