//
//  ViewExtensions.swift
//  Nevvi
//
//  Created by Tyler Cobb on 1/4/23.
//

import Foundation
import SwiftUI

extension View {
    @ViewBuilder
    func redacted(when condition: Bool, redactionType: RedactionType) -> some View {
        if !condition {
            unredacted()
        } else {
            redacted(reason: redactionType)
        }
    }
    
    func redacted(reason: RedactionType?) -> some View {
        self.modifier(Redactable(type: reason))
    }
}
