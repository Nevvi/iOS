//
//  TextExtensions.swift
//  Nevvi
//
//  Created by Tyler Cobb on 1/16/23.
//

import Foundation
import SwiftUI

extension Text {
    func onboardingTitle() -> some View {
        return self
            .font(.system(size: 32))
            .font(.title)
            .bold()
            .foregroundColor(.white)
            .padding([.top], 30)
    }
    
    func onboardingStyle() -> some View {
        return self
            .font(.system(size: 18))
            .multilineTextAlignment(.center)
            .foregroundColor(ColorConstants.accent)
            .shadow(color: Color.black.opacity(0.1), radius: 1, x: 2, y: 2)
    }
    
    func personalInfoLabel() -> some View {
        return self
            .foregroundColor(.secondary)
            .fontWeight(.light)
            .font(.system(size: 14))
    }
    
    func personalInfo() -> some View {
        return self
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(10)
            .foregroundColor(ColorConstants.text)
            .fontWeight(.light)
            .font(.system(size: 20))
            .background(ColorConstants.primary)
            .cornerRadius(10)
            .overlay(RoundedRectangle(cornerRadius: 10.0).strokeBorder(Color.secondary, style: StrokeStyle(lineWidth: 1.0)))
    }
    
    func asTextField() -> some View {
        return self
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .overlay(RoundedRectangle(cornerRadius: 10.0).strokeBorder(Color.secondary, style: StrokeStyle(lineWidth: 1.0)))
    }
}

extension TextField {
    func authStyle() -> some View {
        return self
            .padding()
            .disableAutocorrection(true)
            .autocapitalization(.none)
            .background(.white)
            .cornerRadius(10.0)
            .tint(ColorConstants.text)
    }
    
    func personalInfoStyle() -> some View {
        return self
            .padding(12)
            .overlay(RoundedRectangle(cornerRadius: 10.0).strokeBorder(Color.secondary, style: StrokeStyle(lineWidth: 1.0)))
            .textInputAutocapitalization(.never)
            .disableAutocorrection(true)
            .tint(ColorConstants.text)
    }
}

extension SecureField {
    func authStyle() -> some View {
        return self
            .padding()
            .disableAutocorrection(true)
            .autocapitalization(.none)
            .background(.white)
            .cornerRadius(10.0)
            .tint(ColorConstants.text)
    }
}
