//
//  LoadingView.swift
//  Nevvi
//
//  Created by Tyler Standal on 8/11/25.
//

import SwiftUI

struct LoadingView: View {
    var loadingText: String?
    
    @State private var rotationStep = 0
    @State private var showText = false
    private var rotationTimer: Timer?
    
    init(loadingText: String? = nil) {
        self.loadingText = loadingText
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 40) {
            Image("AppLogo")
                .frame(width: 68, height: 68)
                .rotationEffect(.degrees(Double(rotationStep) * 90))
                .animation(.easeInOut(duration: 0.5), value: rotationStep)
            
            if self.loadingText != nil {
                Text(self.loadingText!)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .opacity(showText ? 1 : 0)
                    .animation(.easeInOut(duration: 0.8).delay(0.3), value: showText)
            }
        }
        .padding(.horizontal, 40)
        .onAppear {
            startSteppedRotation()
            showText = true
        }
        .onDisappear {
            stopRotation()
        }
    }
    
    private func startSteppedRotation() {
        Timer.scheduledTimer(withTimeInterval: 0.6, repeats: true) { timer in
            rotationStep = (rotationStep + 1) % 5 // Adjust % number to match your dot count
        }
    }
    
    private func stopRotation() {
        rotationTimer?.invalidate()
    }
}

struct LoadingView_Preview: PreviewProvider {
    static var previews: some View {
        LoadingView(loadingText: "Hang tight while we fetch your information...")
//        LoadingView()
    }
}
