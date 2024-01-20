//
//  SwiftUIView.swift
//  Nevvi
//
//  Created by Tyler Standal on 1/20/24.
//

import SwiftUI

struct OnboardingButton: View {
    private var text: String
    private var action: () -> Void
    
    init(text: String, action: @escaping () -> Void) {
        self.text = text
        self.action = action
    }
    
    var body: some View {
        Button(action: self.action, label: {
            HStack {
                Text(text.uppercased())
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
            }
            .fontWeight(.bold)
            .frame(maxWidth: .infinity)
            .font(.headline)
            .foregroundColor(.white)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .foregroundColor(ColorConstants.primary)
            )
        })
//        .padding([.bottom], 64)
    }
}

struct OnboardingButton_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingButton(text: "Test") {
            
        }
    }
}
