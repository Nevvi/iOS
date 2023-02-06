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
    
    func errorAlert(error: Binding<Error?>, buttonTitle: String = "OK") -> some View {
        let localizedAlertError = LocalizedAlertError(error: error.wrappedValue)
        return alert(isPresented: .constant(localizedAlertError != nil), error: localizedAlertError) { _ in
            Button(buttonTitle) {
                error.wrappedValue = nil
            }
        } message: { error in
            Text(error.recoverySuggestion ?? "")
        }
    }
}

struct LocalizedAlertError: LocalizedError {
    let underlyingError: LocalizedError
    var errorDescription: String? {
        underlyingError.errorDescription
    }
    var recoverySuggestion: String? {
        underlyingError.recoverySuggestion
    }

    init?(error: Error?) {
        guard let localizedError = error as? LocalizedError else { return nil }
        underlyingError = localizedError
    }
}
