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
        self
            .frame(width: 28, height: 28)
            .padding(8)
            .background(Color(red: 0, green: 0.07, blue: 0.17).opacity(0.03))
            .cornerRadius(40)
    }
}
