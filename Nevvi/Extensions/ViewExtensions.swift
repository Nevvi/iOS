//
//  ViewExtensions.swift
//  Nevvi
//
//  Created by Tyler Cobb on 1/4/23.
//

import Foundation
import SwiftUI

struct HeightPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat?

    static func reduce(value: inout CGFloat?, nextValue: () -> CGFloat?) {
        guard let nextValue = nextValue() else { return }
        value = nextValue
    }
}

private struct ReadHeightModifier: ViewModifier {
    private var sizeView: some View {
        GeometryReader { geometry in
            Color.clear.preference(key: HeightPreferenceKey.self, value: geometry.size.height)
        }
    }

    func body(content: Content) -> some View {
        content.background(sizeView)
    }
}

extension View {
    @ViewBuilder
    func redacted(when condition: Bool, redactionType: RedactionType) -> some View {
        if !condition {
            unredacted()
        } else {
            redacted(reason: redactionType)
        }
    }
    
    func readHeight() -> some View {
        self
            .modifier(ReadHeightModifier())
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
    
//    func placeholder<Content: View>(
//        when shouldShow: Bool,
//        alignment: Alignment = .leading,
//        @ViewBuilder placeholder: () -> Content) -> some View {
//
//        ZStack(alignment: alignment) {
//            placeholder().opacity(shouldShow ? 1 : 0)
//            self
//        }
//    }
    
    #if canImport(UIKit)
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    #endif
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
