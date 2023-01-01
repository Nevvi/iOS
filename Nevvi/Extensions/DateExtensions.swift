//
//  DateExtensions.swift
//  Nevvi
//
//  Created by Tyler Cobb on 1/1/23.
//

import Foundation

extension Date {
    func yyyyMMdd() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: self)
    }
}
