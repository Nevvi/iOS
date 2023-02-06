//
//  NotificationExtensions.swift
//  Nevvi
//
//  Created by Tyler Cobb on 2/5/23.
//

import Foundation
import SwiftUI

extension Notification {
    var keyboardHeight: CGFloat {
        return (userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect)?.height ?? 0
    }
}
