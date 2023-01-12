//
//  BuildConfiguration.swift
//  Nevvi
//
//  Created by Tyler Cobb on 1/8/23.
//

import Foundation

enum BuildEnvironment: String {
    case debugDevelopment = "Debug Development"
    case releaseDevelopment = "Release Development"

    case debugProduction = "Debug Production"
    case releaseProduction = "Release Production"
}

class BuildConfiguration {
    static let shared = BuildConfiguration()
    
    var environment: BuildEnvironment
    
    var baseURL: String {
        switch environment {
        case .debugDevelopment, .releaseDevelopment:
            return "https://api.development.nevvi.net"
        case .debugProduction, .releaseProduction:
            return "https://api.nevvi.net"
        }
    }
    
    init() {
        let currentConfiguration = Bundle.main.object(forInfoDictionaryKey: "Configuration") as! String
        
        environment = BuildEnvironment(rawValue: currentConfiguration)!
    }
}
