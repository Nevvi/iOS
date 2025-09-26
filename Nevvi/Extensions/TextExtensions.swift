//
//  TextExtensions.swift
//  Nevvi
//
//  Created by Tyler Cobb on 1/16/23.
//

import Foundation
import SwiftUI

extension Text {
    func navigationHeader() -> some View {
        return self
            .font(.system(size: 30, weight: .regular))
            .foregroundColor(Color(red: 0.12, green: 0.19, blue: 0.29))
            .frame(maxWidth: .infinity, alignment: .topLeading)
    }
    
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
            .font(.system(size: 20))
            .font(.caption)
            .multilineTextAlignment(.center)
            .foregroundColor(ColorConstants.accent)
            .shadow(color: Color.black.opacity(0.1), radius: 1, x: 2, y: 2)
    }
    
    func personalInfoLabel() -> some View {
        return self
            .font(.system(size: 12, weight: .medium))
            .multilineTextAlignment(.center)
            .foregroundColor(Color(red: 0, green: 0.07, blue: 0.17).opacity(0.4))
    }
    
    func personalInfo() -> some View {
        return self
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(10)
            .foregroundColor(ColorConstants.text)
            .fontWeight(.light)
            .background(ColorConstants.primary)
            .cornerRadius(10)
            .overlay(RoundedRectangle(cornerRadius: 10.0).strokeBorder(Color.secondary, style: StrokeStyle(lineWidth: 1.0)))
    }

    func defaultStyle() -> some View {
        return self.defaultStyle(size: nil, opacity: nil)
    }
    
    func defaultStyle(size: CGFloat?) -> some View {
        return self.defaultStyle(size: size, opacity: 1.0, weight: .regular)
    }
    
    func defaultStyle(size: CGFloat?, opacity: CGFloat?) -> some View {
        return self.defaultStyle(size: size, opacity: opacity, weight: .regular)
    }
    
    func defaultStyle(size: CGFloat?, opacity: CGFloat?, weight: Font.Weight?) -> some View {
        let finalSize = size ?? 24
        let finalOpacity = opacity ?? 1.0
        let finalWeight = weight ?? .regular
        return self
            .font(.system(size: finalSize, weight: finalWeight))
            .foregroundColor(Color(red: 0, green: 0.07, blue: 0.17).opacity(finalOpacity))
    }
    
    func asSelectedGroupFilter() -> some View {
        self
            .font(.system(size: 14, weight: .bold))
            .kerning(0.2)
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(Color(red: 0, green: 0.6, blue: 1))
            .cornerRadius(32)
            .overlay(
                RoundedRectangle(cornerRadius: 32)
                    .inset(by: 0.5)
                    .stroke(Color(red: 0, green: 0.07, blue: 0.17).opacity(0.2), lineWidth: 1)
            )
    }
    
    func asGroupFilter() -> some View {
        self
            .font(.system(size: 14, weight: .bold))
            .kerning(0.2)
            .foregroundColor(Color(red: 0, green: 0.07, blue: 0.17).opacity(0.7))
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(Color(red: 0, green: 0.07, blue: 0.17).opacity(0.02))
            .cornerRadius(32)
            .overlay(
                RoundedRectangle(cornerRadius: 32)
                    .inset(by: 0.5)
                    .stroke(Color(red: 0, green: 0.07, blue: 0.17).opacity(0.2), lineWidth: 1)
            )
    }
    
    func asPermissionGroupBadge(bgColor: Color) -> some View {
        self
            .font(.system(size: 9, weight: .regular))
            .foregroundColor(Color(red: 0.09, green: 0.15, blue: 0.39))
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(bgColor)
            .cornerRadius(Constants.Full)
            .overlay(
                RoundedRectangle(cornerRadius: Constants.Full)
                    .inset(by: -1)
                    .stroke(.white, lineWidth: 2)
            )
    }
    
    func asPrimaryBadge() -> some View {
        self.asBadge(size: 12, color: nil, bgColor: nil)
    }
    
    func asDefaultBadge() -> some View {
        self.asBadge(size: 12, color: Color(red: 0, green: 0.07, blue: 0.17).opacity(0.5), bgColor: Color(red: 0, green: 0.07, blue: 0.17).opacity(0.04))
    }
    
    func asBadge(size: CGFloat?, color: Color?, bgColor: Color?) -> some View {
        let finalSize = size ?? 12
        let finalColor = color ?? Color(red: 0, green: 0.6, blue: 1)
        let finalBgColor = bgColor ?? Color(red: 0, green: 0.6, blue: 1).opacity(0.14)
        return self
            .font(.system(size: finalSize, weight: .medium))
            .foregroundColor(finalColor)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(finalBgColor)
            .cornerRadius(Constants.Full)
    }
    
    func asPrimaryButton() -> some View {
        self
            .fontWeight(.bold)
            .frame(maxWidth: .infinity)
            .font(.subheadline)
            .foregroundColor(.white)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .foregroundColor(ColorConstants.primary)
            )
    }
    
    func asDefaultButton() -> some View {
        self
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity, alignment: .center)
            .background(Color(red: 0, green: 0.07, blue: 0.17).opacity(0.02))
            .cornerRadius(32)
            .overlay(
                RoundedRectangle(cornerRadius: 32)
                    .inset(by: 0.5)
                    .stroke(Color(red: 0, green: 0.07, blue: 0.17).opacity(0.2), lineWidth: 1)
            )
    }
    
    func toolbarTitle() -> some View {
        self
            .fontWeight(.bold)
            .defaultStyle(size: 30, opacity: 1.0)
    }
}

extension TextField {
    func authStyle() -> some View {
        return self
            .submitLabel(.done)
            .font(.system(size: 16, weight: .regular))
            .foregroundColor(Color(red: 0, green: 0.07, blue: 0.17).opacity(0.7))
            .textInputAutocapitalization(.never)
            .disableAutocorrection(true)
    }
    
    func defaultStyle() -> some View {
        return self.defaultStyle(size: nil, opacity: nil, hPadding: nil, vPadding: nil)
    }
    
    func defaultStyle(size: CGFloat?, opacity: CGFloat?) -> some View {
        return self.defaultStyle(size: size, opacity: opacity, hPadding: nil, vPadding: nil)
    }
    
    func defaultStyle(size: CGFloat?, opacity: CGFloat?, hPadding: CGFloat?, vPadding: CGFloat?) -> some View {
        let finalSize = size ?? 24
        let finalOpacity = opacity ?? 1.0
        let finalHPadding = hPadding ?? 10.0
        let finalVPadding = vPadding ?? 12.0
        
        return self
            .submitLabel(.done)
            .font(.system(size: finalSize, weight: .regular))
            .foregroundColor(Color(red: 0, green: 0.07, blue: 0.17).opacity(finalOpacity))
            .padding(.horizontal, finalHPadding)
            .padding(.vertical, finalVPadding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .inset(by: 0.5)
                    .stroke(Color(red: 0, green: 0.07, blue: 0.17).opacity(0.12), lineWidth: 1)
            )
    }
    
    func onboardingStyle() -> some View {
        return self
            .submitLabel(.done)
            .font(.system(size: 16, weight: .regular))
            .padding(14)
            .background(Color.white)
            .cornerRadius(12)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.3), lineWidth: 1))
    }
    
    func bioStyle(size: CGFloat?, opacity: CGFloat?) -> some View {
        let finalSize = size ?? 24
        let finalOpacity = opacity ?? 1.0
        return self
            .submitLabel(.done)
            .font(.system(size: finalSize, weight: .regular))
            .foregroundColor(Color(red: 0, green: 0.07, blue: 0.17).opacity(finalOpacity))
            .textInputAutocapitalization(.never)
            .disableAutocorrection(true)
            .padding(.horizontal, 10)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, minHeight: 87, maxHeight: 87, alignment: .topLeading)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .inset(by: 0.5)
                    .stroke(Color(red: 0, green: 0.07, blue: 0.17).opacity(0.12), lineWidth: 1)
            )
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
