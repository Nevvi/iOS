//
//  ConnectionGroupStore.swift
//  Nevvi
//
//  Created by Tyler Cobb on 12/31/22.
//

import Foundation
import Contacts

class ConnectionGroupStore : ObservableObject {
    @Published var authorization: Authorization? = nil {
        didSet {
            // Reset all state when authorization changes to prevent stale data issues
            if authorization == nil {
                // Reset loading states
                loading = false
                saving = false
                deleting = false
                exporting = false
                reminding = false
                error = nil
                
                // Clear all data - but keep group info since it's set explicitly via load(group:)
                connections = []
                invites = []
                invitedContacts = []
                connectionCount = 0
                skip = 0
            }
            // Note: ConnectionGroupStore loads data when load(group:) is called, not automatically
        }
    }
    
    // TODO - pagination not actually used yet so default to a high limit and just grab all connections right now (500 is max limit)
    private var skip: Int = 0
    private var limit: Int = 500
    private let contactStore = CNContactStore()
    
    @Published var loading: Bool = false
    @Published var loadingInvites: Bool = false
    @Published var saving: Bool = false
    @Published var deleting: Bool = false
    @Published var exporting: Bool = false
    @Published var reminding: Bool = false
    
    @Published var id: String = ""
    @Published var name: String = ""
    @Published var invites: [String] = []
    @Published var invitedContacts: [ContactStore.ContactInfo] = []
    @Published var connections: [Connection] = []
    @Published var connectionCount: Int = 0
    
    @Published var error: Swift.Error?
    
    
    init() {
        
    }
    
    init(group: ConnectionGroup, connections: [Connection], invitedContacts: [ContactStore.ContactInfo]) {
        self.id = group.id
        self.name = group.name
        self.connections = connections
        self.invites = group.invites
        self.invitedContacts = invitedContacts
        self.connectionCount = connections.count
        self.skip = 0
    }
    
    private func groupUrl(groupId: String) throws -> URL {
        if (self.authorization == nil) {
            throw GenericError("Not logged in")
        }
        
        let userId: String = self.authorization!.id
        return URL(string: "\(BuildConfiguration.shared.baseURL)/user/v1/users/\(userId)/connection-groups/\(groupId)?skip=\(self.skip)&limit=\(self.limit)")!
    }
    
    private func groupConnectionsUrl() throws -> URL {
        if (self.authorization == nil) {
            throw GenericError("Not logged in")
        }
        
        let userId: String = self.authorization!.id
        let url = "\(BuildConfiguration.shared.baseURL)/user/v1/users/\(userId)/connection-groups/\(self.id)/connections?skip=\(self.skip)&limit=\(self.limit)"
        
        return URL(string: url)!
    }
    
    private func groupExportUrl() throws -> URL {
        if (self.authorization == nil) {
            throw GenericError("Not logged in")
        }
        
        let userId: String = self.authorization!.id
        return URL(string: "\(BuildConfiguration.shared.baseURL)/user/v1/users/\(userId)/connection-groups/\(self.id)/export")!
    }
    
    private func groupInviteReminderUrl(phoneNumber: String) throws -> URL {
        if (self.authorization == nil) {
            throw GenericError("Not logged in")
        }
        
        let userId: String = self.authorization!.id
        return URL(string: "\(BuildConfiguration.shared.baseURL)/user/v1/users/\(userId)/connection-groups/\(self.id)/invites/\(phoneNumber)")!
    }
    
    func load(group: ConnectionGroup) {
        self.id = group.id
        self.name = group.name
        self.invites = group.invites
        self.skip = 0
        self.loadConnections()
        self.loadInvites()
    }
    
    func loadConnections() {
        do {
            guard let authorization = self.authorization else {
                let error = GenericError("Not logged in")
                self.error = error
                self.loading = false
                return
            }
            
            self.loading = true
            URLSession.shared.fetchData(for: try self.groupConnectionsUrl(), with: authorization) { (result: Result<ConnectionResponse, Error>) in
                switch result {
                case .success(let response):
                    self.connections = response.users
                    self.connectionCount = response.count
                case .failure(let error):
                    self.error = GenericError(error.localizedDescription)
                }
                self.loading = false
            }
        } catch(let error) {
            self.error = GenericError(error.localizedDescription)
            self.loading = false
        }
    }
    
    func loadInvites() {
        let authorizationStatus = CNContactStore.authorizationStatus(for: .contacts)
        guard authorizationStatus == .authorized else {
            // Handle cases for .notDetermined, .denied, or .restricted statuses
            print("Access denied or not determined. Request access first.")
            return
        }
        
        self.loadingInvites = true
        
        let keysToFetch = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey, CNContactThumbnailImageDataKey] as [CNKeyDescriptor]
        
        var contacts: [ContactStore.ContactInfo] = []
        do {
            try self.invites.forEach { number in
                let phoneNumber = CNPhoneNumber(stringValue: number)
                let predicate = CNContact.predicateForContacts(matching: phoneNumber)
                let contact = try contactStore.unifiedContacts(matching: predicate, keysToFetch: keysToFetch).first
                if contact != nil {
                    contacts.append(ContactStore.ContactInfo(firstName: contact!.givenName, lastName: contact!.familyName, phoneNumber: number, image: contact!.thumbnailImageData))
                }
            }
            
            DispatchQueue.global().async {
                self.invitedContacts = contacts.sorted(by: { $0.lastName < $1.lastName })
                self.loadingInvites = false
            }
        } catch {
            print("Failed to fetch contacts, error: \(error.localizedDescription)")
            self.loadingInvites = false
        }
    }
    
    func remindInvite(contact: ContactStore.ContactInfo, callback: @escaping (Result<Bool, Error>) -> Void) {
        do {
            guard let authorization = self.authorization else {
                let error = GenericError("Not logged in")
                self.error = error
                callback(.failure(error))
                self.reminding = false
                return
            }
                        
            self.reminding = true
            
            URLSession.shared.postData(for: try self.groupInviteReminderUrl(phoneNumber: contact.phoneNumber), with: authorization) { (result: Result<Bool, Error>) in
                switch result {
                case .success(_):
                    callback(.success(true))
                case .failure(let error):
                    self.error = GenericError(error.localizedDescription)
                    callback(.failure(error))
                }
                self.reminding = false
            }
        } catch(let error) {
            self.error = GenericError(error.localizedDescription)
            self.reminding = false
        }
    }
    
    func hasNextPage() -> Bool {
        return self.connections.count < self.connectionCount
    }
    
    func isConnectionInGroup(connection: Connection) -> Bool {
        // TODO - call to get connections is paginated so this may not contain every actual connection in the group
        return self.connections.contains { groupConnection in
            return groupConnection.id == connection.id
        }
    }
    
    func addToGroup(userId: String, callback: @escaping (Result<Bool, Error>) -> Void) {
        do {
            guard let authorization = self.authorization else {
                let error = GenericError("Not logged in")
                self.error = error
                callback(.failure(error))
                self.saving = false
                return
            }
            
            self.saving = true
            let request = AddToGroupRequest(userId: userId)
            URLSession.shared.postData(for: try self.groupConnectionsUrl(), for: request, with: authorization) { (result: Result<EmptyResponse, Error>) in
                switch result {
                case .success(_):
                    callback(.success(true))
                case .failure(let error):
                    self.error = GenericError(error.localizedDescription)
                    callback(.failure(error))
                }
                self.saving = false
            }
        } catch(let error) {
            self.error = GenericError(error.localizedDescription)
            callback(.failure(error))
            self.saving = false
        }
    }
    
    func removeFromGroup(userId: String, callback: @escaping (Result<Bool, Error>) -> Void) {
        do {
            guard let authorization = self.authorization else {
                let error = GenericError("Not logged in")
                self.error = error
                callback(.failure(error))
                self.deleting = false
                return
            }
            
            self.deleting = true
            let request = RemoveFromGroupRequest(userId: userId)
            URLSession.shared.deleteData(for: try self.groupConnectionsUrl(), for: request, with: authorization) { (result: Result<EmptyResponse, Error>) in
                switch result {
                case .success(_):
                    callback(.success(true))
                case .failure(let error):
                    self.error = GenericError(error.localizedDescription)
                    callback(.failure(error))
                }
                self.deleting = false
            }
        } catch(let error) {
            self.error = GenericError(error.localizedDescription)
            callback(.failure(error))
            self.deleting = false
        }
    }
    
    func exportGroupData(callback: @escaping (Result<Bool, Error>) -> Void) {
        do {
            guard let authorization = self.authorization else {
                let error = GenericError("Not logged in")
                self.error = error
                callback(.failure(error))
                self.exporting = false
                return
            }
            
            self.exporting = true
            URLSession.shared.postData(for: try self.groupExportUrl(), with: authorization) { (result: Result<EmptyResponse, Error>) in
                switch result {
                case .success(_):
                    callback(.success(true))
                case .failure(let error):
                    self.error = GenericError(error.localizedDescription)
                    callback(.failure(error))
                }
                self.exporting = false
            }
        } catch(let error) {
            self.error = GenericError(error.localizedDescription)
            callback(.failure(error))
            self.exporting = false
        }
    }

    struct AddToGroupRequest : Encodable {
        var userId: String
    }
    
    struct RemoveFromGroupRequest : Encodable {
        var userId: String
    }
    
    struct EmptyResponse : Decodable {
        
    }
    
}
