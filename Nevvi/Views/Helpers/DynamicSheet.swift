//
//  DynamicSheet.swift
//  Nevvi
//
//  Created by Tyler Standal on 1/27/24.
//

import Foundation
import SwiftUI

struct DynamicSheet<Content: View>: View {
    @State var detentHeight: CGFloat = 0
    
    let build: () -> Content
    init(_ build: @autoclosure @escaping () -> Content) {
        self.build = build
    }

    var body: some View {
        build()
            .readHeight()
            .onPreferenceChange(HeightPreferenceKey.self) { height in
                if let height {
                    self.detentHeight = height
                }
            }
            .presentationDetents([.height(self.detentHeight)])
    }
}

struct DynamicSheet_Previews: PreviewProvider {
    static var previews: some View {
        DynamicSheet(
            Text("Hello world")
        )
    }
}
