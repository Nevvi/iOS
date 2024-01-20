//
//  StackExtensions.swift
//  Nevvi
//
//  Created by Tyler Standal on 1/20/24.
//

import Foundation
import SwiftUI

extension VStack {
    func informationSection() -> some View {
        self
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 8)
            .frame(maxWidth: .infinity, alignment: .topLeading)
            .background(.white)
            .cornerRadius(16)
    }
}
