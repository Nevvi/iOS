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
    @Published var authorization: Authorization? = nil {
        didSet {
            // Reset all state when authorization changes to prevent stale data issues
            if authorization == nil {
                // Reset loading states
                loading = false
                saving = false
                error = nil
                
                // Clear notification token
                token = ""
            }
        }
    }
    
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
        
        let userId: String = self.authorization!.id
        return URL(string: "\(BuildConfiguration.shared.baseURL)/notification/v1/users/\(userId)/notifications")!
    }
    
    private func tokenUrl() throws -> URL {
        if (self.authorization == nil) {
            throw GenericError("Not logged in")
        }
        
        let userId: String = self.authorization!.id
        return URL(string: "\(BuildConfiguration.shared.baseURL)/notification/v1/users/\(userId)/notifications/token")!
    }
    
    func checkRequestAccess() -> Void {
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.hasAccess = settings.authorizationStatus == .authorized
                self.canRequestAccess = settings.authorizationStatus == .notDetermined
            }
        }
    }
    
    func updateToken(token: String) {
        do {
            guard let authorization = self.authorization else {
                let error = GenericError("Not logged in")
                self.error = error
                self.saving = false
                return
            }
            
            self.saving = true
            let request = UpdateTokenRequest(token: token)
            URLSession.shared.postData(for: try self.tokenUrl(), for: request, with: authorization) { (result: Result<UpdateTokenResponse, Error>) in
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


