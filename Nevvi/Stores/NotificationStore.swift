//
//  NotificationStore.swift
//  Nevvi
//
//  Created by Tyler Cobb on 1/30/23.
//

import Foundation
import UIKit
import SwiftUI

class NotificationStore: ObservableObject {
    var authorization: Authorization? = nil
    
    // TODO - grab token from API on startup
    @Published var token: String = ""
    @Published var loading: Bool = false
    @Published var saving: Bool = false
    @Published var error: Swift.Error?
    
    @Published var hasAccess: Bool = false
    @Published var canRequestAccess: Bool = false
        
    init() {
        self.checkRequestAccess()
    }
    
    private func url() throws -> URL {
        if (self.authorization == nil) {
            throw GenericError("Not logged in")
        }
        
        let userId: String? = self.authorization?.id
        return URL(string: "\(BuildConfiguration.shared.baseURL)/notification/v1/users/\(userId!)/notifications")!
    }
    
    private func tokenUrl() throws -> URL {
        if (self.authorization == nil) {
            throw GenericError("Not logged in")
        }
        
        let userId: String? = self.authorization?.id
        return URL(string: "\(BuildConfiguration.shared.baseURL)/notification/v1/users/\(userId!)/notifications/token")!
    }
    
    func checkRequestAccess() -> Void {
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { settings in
            print(settings.authorizationStatus)
            DispatchQueue.main.async {
                self.hasAccess = settings.authorizationStatus == .authorized
                self.canRequestAccess = settings.authorizationStatus == .notDetermined
            }
        }
    }
    
    func updateToken(token: String) {
        do {
            self.saving = true
            let idToken: String? = self.authorization?.idToken
            let request = UpdateTokenRequest(token: token)
            URLSession.shared.postData(for: try self.tokenUrl(), for: request, for: "Bearer \(idToken!)") { (result: Result<UpdateTokenResponse, Error>) in
                switch result {
                case .success(_):
                    self.token = token
                case .failure(let error):
                    self.error = GenericError(error.localizedDescription)
                }
                self.saving = false
            }
        } catch(let error) {
            self.error = GenericError(error.localizedDescription)
            self.saving = false
        }
    }
    
    struct UpdateTokenRequest: Encodable {
        var token: String?
    }

    struct UpdateTokenResponse: Decodable {
        
    }
}


