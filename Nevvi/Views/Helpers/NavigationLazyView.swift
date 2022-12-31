//
//  NavigationLazyView.swift
//  Nevvi
//
//  Created by Tyler Cobb on 12/31/22.
//

import Foundation
import SwiftUI

struct NavigationLazyView<Content: View>: View {
    let build: () -> Content
    init(_ build: @autoclosure @escaping () -> Content) {
        self.build = build
    }
    var body: Content {
        build()
    }
}
