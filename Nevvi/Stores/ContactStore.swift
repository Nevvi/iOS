//
//  ContactStore.swift
//  Nevvi
//
//  Created by Tyler Cobb on 1/5/23.
//

import Contacts

class ContactStore: ObservableObject {
    var authorization: Authorization? = nil
    var phoneNumbers: [String] = []
    
    @Published var loading: Bool = false
    @Published var error: Swift.Error?
    
    private var CNLabelMail = "mail"
    
    private func connectionUrl(connectionId: String) throws -> URL {
        if (self.authorization == nil) {
            throw GenericError("Not logged in")
        }
        
        let userId: String? = self.authorization?.id
        return URL(string: "\(BuildConfiguration.shared.baseURL)/user/v1/users/\(userId!)/connections/\(connectionId)")!
    }
    
    func hasAccess() -> Bool {
        let authStatus = CNContactStore.authorizationStatus(for: .contacts)
        switch authStatus {
            case .authorized:
                return true
            default:
                return false
        }
    }
    
    func canRequestAccess() -> Bool {
        let authStatus = CNContactStore.authorizationStatus(for: .contacts)
        return authStatus == .notDetermined
    }
    
    func tryRequestAccess() -> Bool {
        let authStatus = CNContactStore.authorizationStatus(for: .contacts)
        switch authStatus {
        case .authorized:
            return true
        case .notDetermined:
            let store = CNContactStore()
            store.requestAccess(for: .contacts) { success, error in
                if !success {
                    print("Not authorized to access contacts. Error = \(String(describing: error))")
                }
            }
            return true
        default:
            print("Failed to request contact access because auth status is \(authStatus)")
            return false;
        }
    }
    
    func updateConnection(connectionId: String, callback: @escaping (Result<Connection, Error>) -> Void) {
        do {
            self.loading = true
            let idToken: String? = self.authorization?.idToken
            let request = UpdateRequest(inSync: true)
            URLSession.shared.patchData(for: try self.connectionUrl(connectionId: connectionId), for: request, for: "Bearer \(idToken!)") { (result: Result<Connection, Error>) in
                switch result {
                case .success(let connection):
                    callback(.success(connection))
                case .failure(let error):
                    callback(.failure(error))
                }
                self.loading = false
            }
        } catch(let error) {
            self.loading = false
            callback(.failure(error))
        }
    }
    
    func getConnection(connectionId: String, callback: @escaping (Result<Connection, Error>) -> Void) {
        do {
            let idToken: String? = self.authorization?.idToken
            URLSession.shared.fetchData(for: try self.connectionUrl(connectionId: connectionId), for: "Bearer \(idToken!)") { (result: Result<Connection, Error>) in
                switch result {
                case .success(let detail):
                    callback(.success(detail))
                case .failure(let failure):
                    callback(.failure(failure))
                }
            }
        } catch(let error) {
            callback(.failure(error))
        }
    }
    
    func syncContacts(connections: [Connection], dryRun: Bool, callback: @escaping (SyncInfo) -> Void) {
        let store = CNContactStore()
        let dispatchGroup = DispatchGroup()
        
        var contactSyncInfos: [ContactSyncInfo] = []
        let addressFormatter = CNPostalAddressFormatter()
        
        connections.forEach { connection in
            dispatchGroup.enter()
            self.getConnection(connectionId: connection.id) { (connectionDetail: Result<Connection, Error>) in
                switch connectionDetail {
                case .success(let detail):
                    do {
                        let keysToFetch = [CNContactGivenNameKey,
                                           CNContactFamilyNameKey,
                                           CNContactPhoneNumbersKey,
                                           CNContactEmailAddressesKey,
                                           CNContactPostalAddressesKey,
                                           CNContactJobTitleKey,
                                           CNContactBirthdayKey] as [CNKeyDescriptor]
                        
                        var contactOpt: CNMutableContact? = nil
                        var contactFieldChanges: [ContactSyncFieldInfo] = []
                        
                        if detail.phoneNumber != nil {
                            print("Searching for contact with phone", detail.phoneNumber!)
                            let predicate = CNContact.predicateForContacts(matching: CNPhoneNumber(stringValue: detail.phoneNumber!))
                            let contacts = try store.unifiedContacts(matching: predicate, keysToFetch: keysToFetch)
                            if contacts.count == 1 {
                                print("Found contacts by phone", contacts)
                                contactOpt = contacts[0].mutableCopy() as? CNMutableContact
                            }
                        }
                        
                        if contactOpt == nil && detail.email != nil {
                            print("Searching for contact with email", detail.email!)
                            let predicate = CNContact.predicateForContacts(matchingEmailAddress: detail.email!)
                            let contacts = try store.unifiedContacts(matching: predicate, keysToFetch: keysToFetch)
                            if contacts.count == 1 {
                                print("Found contacts by email", contacts)
                                contactOpt = contacts[0].mutableCopy() as? CNMutableContact
                            }
                        }
                        
                        if contactOpt == nil {
                            print("Searching for contact by name", detail.firstName, detail.lastName)
                            let predicate = CNContact.predicateForContacts(matchingName: "\(detail.firstName) \(detail.lastName)")
                            let contacts = try store.unifiedContacts(matching: predicate, keysToFetch: keysToFetch)
                            if contacts.count == 1 {
                                print("Found contacts by name", contacts)
                                contactOpt = contacts[0].mutableCopy() as? CNMutableContact
                            }
                        }
                        
                        let contact = contactOpt == nil ? CNMutableContact() : contactOpt!
                        
                        if detail.bio != nil {
                            let bioChange = ContactSyncFieldInfo(field: "Bio", oldValue: contact.jobTitle, newValue: detail.bio)
                            contact.jobTitle = detail.bio!
                            contactFieldChanges.append(bioChange)
                        }

                        let utcDateFormatter = DateFormatter()
                        utcDateFormatter.dateStyle = .medium
                        utcDateFormatter.timeStyle = .none
                        utcDateFormatter.timeZone = TimeZone(abbreviation: "UTC")
                        
                        if detail.birthday != nil {
                            var existingBirthday: String? = nil
                            if let birthday = contact.birthday {
                                existingBirthday = utcDateFormatter.string(from: birthday.date!)
                            }
                            
                            let newBirthday = utcDateFormatter.string(from: detail.birthday!)
                            contact.birthday = Calendar.current.dateComponents([.year, .month, .day], from: detail.birthday!)
                            let birthdayChange = ContactSyncFieldInfo(field: "Birthday", oldValue: existingBirthday, newValue: newBirthday)
                            contactFieldChanges.append(birthdayChange)
                        }
                        
                        // We own the home address and mailing address :)
                        if detail.address != nil &&  detail.address!.street != nil {
                            let existingHomeAddress = contact.postalAddresses.first { (address: CNLabeledValue<CNPostalAddress>) in
                                address.label == CNLabelHome
                            }
                            contact.postalAddresses.removeAll { (address: CNLabeledValue<CNPostalAddress>) in
                                address.label == CNLabelHome
                            }
                            
                            let address = CNMutablePostalAddress()
                            address.street = detail.address!.street!
                            if let unit = detail.address?.unit {
                                address.subLocality = unit
                                address.street = "\(address.street) \(unit)"
                            }
                            
                            address.city = detail.address!.city!
                            address.state = detail.address!.state!
                            address.postalCode = String(detail.address!.zipCode!)
                            contact.postalAddresses.append(CNLabeledValue(label: CNLabelHome, value: address))
                            
                            var oldAddress: String? = nil
                            let newAddress: String? = addressFormatter.string(from: address).stripLineBreaks()
                            if let existingHomeAddress = existingHomeAddress {
                                oldAddress = addressFormatter.string(from: existingHomeAddress.value).stripLineBreaks()
                            }
                            
                            let addressChange = ContactSyncFieldInfo(field: "Address", oldValue: oldAddress, newValue: newAddress)
                            contactFieldChanges.append(addressChange)
                        }
                        
                        if detail.mailingAddress != nil &&  detail.mailingAddress!.street != nil {
                            let existingMailingAddress = contact.postalAddresses.first { (address: CNLabeledValue<CNPostalAddress>) in
                                address.label == self.CNLabelMail
                            }
                            contact.postalAddresses.removeAll { (address: CNLabeledValue<CNPostalAddress>) in
                                address.label == self.CNLabelMail
                            }
                            
                            let address = CNMutablePostalAddress()
                            address.street = detail.mailingAddress!.street!
                            if let unit = detail.mailingAddress?.unit {
                                address.subLocality = unit
                                address.street = "\(address.street) \(unit)"
                            }
                            
                            address.city = detail.mailingAddress!.city!
                            address.state = detail.mailingAddress!.state!
                            address.postalCode = String(detail.mailingAddress!.zipCode!)
                            contact.postalAddresses.append(CNLabeledValue(label: self.CNLabelMail, value: address))
                            
                            var oldAddress: String? = nil
                            let newAddress: String? = addressFormatter.string(from: address).stripLineBreaks()
                            if let existingMailingAddress = existingMailingAddress {
                                oldAddress = addressFormatter.string(from: existingMailingAddress.value).stripLineBreaks()
                            }
                            
                            let addressChange = ContactSyncFieldInfo(field: "Mailing Address", oldValue: oldAddress, newValue: newAddress)
                            contactFieldChanges.append(addressChange)
                        }
                                                      
                        // We own the mobile number :)
                        if detail.phoneNumber != nil {
                            let existingPhoneNumber = contact.phoneNumbers.first { (phoneNumber: CNLabeledValue<CNPhoneNumber>) in
                                phoneNumber.label == CNLabelPhoneNumberMobile
                            }
                            contact.phoneNumbers.removeAll(where: { (phoneNumber: CNLabeledValue<CNPhoneNumber>) in
                                phoneNumber.label == CNLabelPhoneNumberMobile
                            })
                            
                            let phoneNumber = CNPhoneNumber(stringValue: detail.phoneNumber!)
                            contact.phoneNumbers.append(CNLabeledValue(label: CNLabelPhoneNumberMobile, value: phoneNumber))
                        
                            let phoneChange = ContactSyncFieldInfo(field: "Phone Number", oldValue: existingPhoneNumber?.value.stringValue, newValue: phoneNumber.stringValue)
                            contactFieldChanges.append(phoneChange)
                        }
                        
                        // We own the home email :)
                        if detail.email != nil {
                            let existingEmail = contact.emailAddresses.first { (email: CNLabeledValue<NSString>) in
                                email.label == CNLabelHome
                            }
                            contact.emailAddresses.removeAll(where: { (email: CNLabeledValue<NSString>) in
                                email.label == CNLabelHome
                            })
                            
                            let email = NSString(string: detail.email!)
                            contact.emailAddresses.append(CNLabeledValue(label: CNLabelHome, value: email))
                            
                            let emailChange = ContactSyncFieldInfo(field: "Email", oldValue: existingEmail?.value.description, newValue: detail.email)
                            contactFieldChanges.append(emailChange)
                        }
                        

                        let saveRequest = CNSaveRequest()
                        if contactOpt == nil {
                            // Only update name if creating this contact for the first time
                            contact.givenName = detail.firstName
                            contact.familyName = detail.lastName
                            saveRequest.add(contact, toContainerWithIdentifier: nil)
                            contactSyncInfos.append(ContactSyncInfo(connection: detail, updatedFields: contactFieldChanges, isUpdate: false))
                        } else {
                            saveRequest.update(contact)
                            // We don't actually modify the name right now... keep that the same
                            contactSyncInfos.append(ContactSyncInfo(connection: detail, updatedFields: contactFieldChanges, isUpdate: true))
                        }
                            
                        if (!dryRun) {
                            do {
                                try store.execute(saveRequest)
                            } catch {
                                print("Error occur: \(error)")
                            }
                        }
                        
                    } catch (let error) {
                        print(error)
                    }
                case .failure(let failure):
                    print(failure)
                }
                
                if (!dryRun) {
                    self.updateConnection(connectionId: connection.id) {_ in
                        dispatchGroup.leave()
                    }
                } else {
                    dispatchGroup.leave()
                }
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            print("Done syncing \(connections.count) contacts")
            callback(SyncInfo(updatedContacts: contactSyncInfos))
        }
    }
    
    struct UpdateRequest: Encodable {
        var inSync: Bool
    }
    
    struct ContactSyncFieldInfo {
        var field: String
        var oldValue: String?
        var newValue: String?
    }
    
    struct ContactSyncInfo {
        var connection: Connection
        var updatedFields: [ContactSyncFieldInfo]
        var isUpdate: Bool // true if updating contact, false if creating contact
        
        func changedFields() -> [ContactSyncFieldInfo] {
            return self.updatedFields.filter { fieldUpdate in
                fieldUpdate.oldValue != fieldUpdate.newValue
            }
        }
    }
    
    struct SyncInfo {
        var updatedContacts: [ContactSyncInfo]
    }
}
