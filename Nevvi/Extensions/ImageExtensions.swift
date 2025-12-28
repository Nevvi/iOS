//
//  ImageExtensions.swift
//  Nevvi
//
//  Created by Tyler Standal on 1/20/24.
//

import Foundation
import SwiftUI

extension Image {
    func toolbarButtonStyle() -> some View {
        self.toolbarButtonStyle(bgColor: Color(red: 0, green: 0.07, blue: 0.17).opacity(0.03))
    }
    
    func toolbarButtonStyle(bgColor: Color) -> some View {
        self
            .frame(width: 28, height: 28)
            .padding(8)
            .background {
                if #unavailable(iOS 18.0) {
                    bgColor
                }
            }
            .modifier(ConditionalCornerRadiusModifier())
    }
    
    func buttonStyle() -> some View {
        self.buttonStyle(bgColor: Color(red: 0, green: 0.07, blue: 0.17).opacity(0.03))
    }
    
    func buttonStyle(bgColor: Color) -> some View {
        self
            .frame(width: 28, height: 28)
            .padding(8)
            .background {
                bgColor
            }
            .clipShape(RoundedRectangle(cornerRadius: 40))
    }
    
    func settingsButtonStyle() -> some View {
        self
            .frame(width: 28, height: 28)
            .padding(4)
            .background {
                if #unavailable(iOS 18.0) {
                    Color(red: 0, green: 0.07, blue: 0.17).opacity(0.03)
                }
            }
            .modifier(ConditionalCornerRadiusModifier())
            .padding(.trailing, 8)
    }
}

struct ConditionalCornerRadiusModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 18.0, *) {
            content
                .clipShape(RoundedRectangle(cornerRadius: 0))
        } else {
            content
                .clipShape(RoundedRectangle(cornerRadius: 40))
        }
    }
}
