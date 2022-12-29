//
//  GenericError.swift
//  Nevvi
//
//  Created by Tyler Cobb on 12/29/22.
//

import Foundation

struct GenericError : LocalizedError
{
    var errorDescription: String? { return mMsg }
    var failureReason: String? { return mMsg }
    var recoverySuggestion: String? { return "" }
    var helpAnchor: String? { return "" }

    private var mMsg : String

    init(_ description: String)
    {
        mMsg = description
    }
}
