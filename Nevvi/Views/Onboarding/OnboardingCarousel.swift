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
    
    var body: some View {
        VStack {
            TabView(selection: $index) {
                OnboardingIntro(primaryClick: {
                    self.index = 1
                })
                .tabStyle(page: 0)
                
                OnboardingDescription(primaryClick: {
                    self.index = 2
                }).tabStyle(page: 1)
                
                OnboardingSync(primaryClick: {
                    print("Done onboarding!")
                }).tabStyle(page: 2)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .edgesIgnoringSafeArea([.top])
            .animation(.easeOut(duration: 0.2), value: index)
            
            HStack(spacing: 3) {
                ForEach((0..<3), id: \.self) { index in
                    Rectangle()
                        .fill(index == self.index ? Color.black : Color.black.opacity(0.2))
                        .frame(width: 30, height: 3)

                }
            }
            .padding()
        }
    }
}

struct Onboarding_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingCarousel()
            .environmentObject(AccountStore(user: ModelData().user))
    }
}
