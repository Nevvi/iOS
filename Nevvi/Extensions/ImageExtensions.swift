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
        self.toolbarButtonStyle(bgColor: self.adaptiveBackgroundColor)
    }
    
    func toolbarButtonStyle(bgColor: Color) -> some View {
        self
            .frame(width: 28, height: 28)
            .padding(8)
            .background(bgColor)
            .cornerRadius(40)
    }
    
    func settingsButtonStyle() -> some View {
        self
            .frame(width: 28, height: 28)
            .padding(4)
            .background(Color(red: 0, green: 0.07, blue: 0.17).opacity(0.03))
            .cornerRadius(40)
            .padding(.trailing, 8)
    }
    
    // Helper to get appropriate background color based on iOS version
    private var adaptiveBackgroundColor: Color {
        if #available(iOS 26.0, *) {
            return .clear
        } else {
            return Color(red: 0, green: 0.07, blue: 0.17).opacity(0.03)
        }
    }
}
