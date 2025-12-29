//
//  Onboarding.swift
//  Nevvi
//
//  Created by Tyler Cobb on 12/30/22.
//

import SwiftUI

extension View {
    func tabStyle(page: Int) -> some View {
        return self
            .tag(page)
            .gesture(DragGesture())
    }
}

struct OnboardingCarousel: View {
    @State var index = 0
    @EnvironmentObject var accountStore: AccountStore
    @EnvironmentObject var contactStore: ContactStore
    
    var body: some View {
        VStack {
            TabView(selection: $index) {
                OnboardingIntro(primaryClick: {
                    self.index = 1
                })
                .tabStyle(page: 0)
                
                OnboardingPermissionGroups(primaryClick: {
                    self.index = 2
                }).tabStyle(page: 1)
                
                OnboardingConnectionGroups(primaryClick: {
                    self.index = 3
                }).tabStyle(page: 2)
                
                OnboardingProfile(primaryClick: {
                    if (self.contactStore.canRequestAccess() || self.contactStore.hasAccess()) {
                        print("Has or can request contact access")
                        self.index = 4
                    } else {
                        print("Can't request contact access")
                        self.index = 5
                    }
                }).tabStyle(page: 3)
                
                OnboardingContactsPrompt(primaryClick: {
                    self.index = 5
                }).tabStyle(page: 4)
                
                OnboardingSuccess(primaryClick: {
                    print("Done onboarding!")
                }).tabStyle(page: 5)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .edgesIgnoringSafeArea([.top])
            .animation(.easeOut(duration: 0.2), value: index)
            
            HStack(spacing: 3) {
                ForEach((0..<6), id: \.self) { index in
                    Rectangle()
                        .fill(index == self.index ? Color.black : Color.black.opacity(0.2))
                        .frame(width: 30, height: 3)

                }
            }
        }
    }
}

struct Onboarding_Previews: PreviewProvider {
    static let modelData = ModelData()
    static let contactStore = ContactStore()
    static let accountStore = AccountStore(user: modelData.user)
    
    static var previews: some View {
        OnboardingCarousel()
            .environmentObject(accountStore)
            .environmentObject(contactStore)
    }
}
