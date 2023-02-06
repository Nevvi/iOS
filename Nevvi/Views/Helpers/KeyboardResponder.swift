//
//  KeyboardResponder.swift
//  Nevvi
//
//  Created by Tyler Cobb on 2/5/23.
//

import SwiftUI
import Combine

struct KeyboardResponder: ViewModifier {
    @State private var bottomPadding: CGFloat = 0

    func body(content: Content) -> some View {
        GeometryReader { geometry in
            content
                .padding(.bottom, self.bottomPadding)
                .onReceive(Publishers.keyboardHeight) { keyboardHeight in
                    let keyboardTop = geometry.frame(in: .global).height - keyboardHeight
                    let focusedTextInputBottom = UIResponder.currentFirstResponder?.globalFrame?.maxY ?? 0
                    self.bottomPadding = max(0, focusedTextInputBottom - keyboardTop - geometry.safeAreaInsets.bottom)
                    print(keyboardTop, focusedTextInputBottom, self.bottomPadding, geometry.safeAreaInsets.bottom)
                }
        }
    }
}
