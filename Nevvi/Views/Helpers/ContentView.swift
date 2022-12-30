//
//  ContentView.swift
//  Nevvi
//
//  Created by Tyler Cobb on 12/29/22.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var accountStore: AccountStore
    
    var body: some View {
        if (accountStore.user != nil) {
            if (accountStore.user!.onboardingCompleted) {
                TabView {
                    Account(user: accountStore.user!).tabItem() {
                        Image(systemName: "person.fill")
                        Text("Account")
                    }
                    ConnectionList().tabItem() {
                        Image(systemName: "person.3.fill")
                        Text("Connections")
                    }
                }
            } else {
                OnboardingCarousel(accountStore: self.accountStore)
            }
        } else {
            // TODO - better loading view
            ProgressView().onAppear(perform: self.accountStore.load)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(accountStore: AccountStore()).environmentObject(ModelData())
    }
}
