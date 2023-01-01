//
//  RefreshableView.swift
//  Nevvi
//
//  Created by Tyler Cobb on 1/1/23.
//

import Foundation
import SwiftUI
import UIKit

struct RefreshableView<Content: View>: View {
    var onRefresh: () -> Void
    var view: Content
    
    var body: some View {
        view.refreshable {
            self.onRefresh()
        }
    }
}

struct RefreshableView_Previews: PreviewProvider {
    static var previews: some View {
        RefreshableView(onRefresh: {}, view: Text("Hello, World"))
    }
}
