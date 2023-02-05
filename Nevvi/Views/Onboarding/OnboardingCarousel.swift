//
//  Onboarding.swift
//  Nevvi
//
//  Created by Tyler Cobb on 12/30/22.
//

import SwiftUI

extension View {
    func tabStyle(page: Int) -> some View {
        return self.tag(page).gesture(DragGesture())
    }
}

struct OnboardingCarousel: View {
    @State var index = 0
    @EnvironmentObject var accountStore: AccountStore
    
    var body: some View {
        VStack{
            TabView(selection: $index) {
                OnboardingIntro(primaryClick: {
                    self.index = 1
                }).tabStyle(page: 0)
                
                OnboardingDescription(primaryClick: {
                    self.index = 2
                }, secondaryClick: {
                    self.index = 0
                }).tabStyle(page: 1)
                
                OnboardingDescriptionCont(primaryClick: {
                    self.index = 3
                }, secondaryClick: {
                    self.index = 1
                }).tabStyle(page: 2)
                
                OnboardingInformation(primaryClick: {
                    self.index = 4
                }, secondaryClick: {
                    self.index = 2
                }).tabStyle(page: 3)
                
                OnboardingSync(primaryClick: {
                    print("Done onboarding!")
                }, secondaryClick: {
                    self.index = 3
                }).tabStyle(page: 4)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .edgesIgnoringSafeArea([.all])
            .animation(.easeOut(duration: 0.2), value: index)
        }
    }
}

struct Onboarding_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingCarousel()
            .environmentObject(AccountStore(user: ModelData().user))
    }
}
