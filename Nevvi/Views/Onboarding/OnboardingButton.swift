//
//  SwiftUIView.swift
//  Nevvi
//
//  Created by Tyler Standal on 1/20/24.
//

import SwiftUI

struct OnboardingButton: View {
    private var text: String
    private var primary: Bool
    private var action: () -> Void
    
    init(text: String, action: @escaping () -> Void) {
        self.text = text
        self.primary = true
        self.action = action
    }
    
    init(text: String, primary: Bool, action: @escaping () -> Void) {
        self.text = text
        self.primary = primary
        self.action = action
    }
    
    var body: some View {
        if self.primary {
            primaryButton
        } else  {
            secondaryButton
        }
    }
    
    var primaryButton: some View {
        Button(action: self.action, label: {
            HStack {
                Text(text.uppercased())
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
            }
            .fontWeight(.bold)
            .frame(maxWidth: .infinity)
            .font(.subheadline)
            .foregroundColor(.white)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .foregroundColor(ColorConstants.primary)
            )
        })
    }
    
    var secondaryButton: some View {
        Button(action: self.action, label: {
            HStack {
                Text(text.uppercased())
            }
            .fontWeight(.bold)
            .frame(maxWidth: .infinity)
            .font(.subheadline)
            .foregroundColor(.black)
            .padding(.vertical, 16)
            .background(Color(UIColor(hexString: "#f0f2f5")))
            .cornerRadius(24)
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(Color(red: 0, green: 0.07, blue: 0.17).opacity(0.2), lineWidth: 1)
            )
        })
    }
}

struct OnboardingButton_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingButton(text: "Test", primary: false) {
            
        }
    }
}
