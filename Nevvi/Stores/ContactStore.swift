//
//  ContactStore.swift
//  Nevvi
//
//  Created by Tyler Cobb on 1/5/23.
//

import Contacts

class ContactStore {
    var authorization: Authorization? = nil
    
    private var limit: Int = 20
    @Published var error: Swift.Error?
    
    private func url(skip: Int, limit: Int) throws -> URL {
        if (self.authorization == nil) {
            throw GenericError("Not logged in")
        }
        
        let userId: String? = self.authorization?.id
        return URL(string: "https://api.development.nevvi.net/user/v1/users/\(userId!)/connections?limit=\(limit)&skip=\(skip)")!
    }
    
    private func connectionUrl(connectionId: String) throws -> URL {
        if (self.authorization == nil) {
            throw GenericError("Not logged in")
        }
        
        let userId: String? = self.authorization?.id
        return URL(string: "https://api.development.nevvi.net/user/v1/users/\(userId!)/connections/\(connectionId)")!
    }
    
    // TODO - make this recursive
    private func processConnections(skip: Int = 0, limit: Int = 25, callback: @escaping (Result<[Connection], Error>) -> Void) {
        do {
            let idToken: String? = self.authorization?.idToken
            
            URLSession.shared.fetchData(for: try self.url(skip: skip, limit: limit), for: "Bearer \(idToken!)") { (result: Result<ConnectionResponse, Error>) in
                switch result {
                case .success(let response):
                    callback(.success(response.users))
                case .failure(let error):
                    callback(.failure(error))
                }
            }
        } catch(let error) {
            callback(.failure(error))
        }
    }
    
    func processConnection(connectionId: String, callback: @escaping (Result<Connection, Error>) -> Void) {
        do {
            let idToken: String? = self.authorization?.idToken
            URLSession.shared.fetchData(for: try self.connectionUrl(connectionId: connectionId), for: "Bearer \(idToken!)") { (result: Result<Connection, Error>) in
                switch result {
                case .success(let connection):
                    callback(.success(connection))
                case .failure(let error):
                    callback(.failure(error))
                }
            }
        } catch(let error) {
            callback(.failure(error))
        }
    }
    
    func syncAllContacts() {
        let store = CNContactStore()
        self.processConnections { (result: Result<[Connection], Error>) in
            switch result {
            case.failure(let error):
                print(error)
            case.success(let connections):
                connections.forEach { connection in
                    self.processConnection(connectionId: connection.id) { (connectionDetail: Result<Connection, Error>) in
                        switch connectionDetail {
                        case .success(let detail):
                            do {
                                let keysToFetch = [CNContactGivenNameKey,
                                                   CNContactFamilyNameKey,
                                                   CNContactPhoneNumbersKey,
                                                   CNContactEmailAddressesKey,
                                                   CNContactPostalAddressesKey,
                                                   CNContactBirthdayKey] as [CNKeyDescriptor]
                                
                                var contactOpt: CNMutableContact? = nil
                                
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
                                
                                // TODO - check if they want this setting
                                contact.givenName = detail.firstName
                                contact.familyName = detail.lastName
                                
                                if detail.birthday != nil {
                                    contact.birthday = Calendar.current.dateComponents([.year, .month, .day], from: detail.birthday!)
                                }
                                
                                // We own the home address :)
                                contact.postalAddresses.removeAll { (address: CNLabeledValue<CNPostalAddress>) in
                                    address.label == CNLabelHome
                                }
                                if detail.address != nil &&  detail.address!.street != nil {
                                    let address = CNMutablePostalAddress()
                                    address.street = detail.address!.street!
                                    address.city = detail.address!.city!
                                    address.state = detail.address!.state!
                                    address.postalCode = String(detail.address!.zipCode!)
                                    address.country = "US"
                                    contact.postalAddresses.append(CNLabeledValue(label: CNLabelHome, value: address))
                                }
                                                              
                                // We own the iPhone number :)
                                contact.phoneNumbers.removeAll(where: { (phoneNumber: CNLabeledValue<CNPhoneNumber>) in
                                    phoneNumber.label == CNLabelPhoneNumberiPhone
                                })
                                if detail.phoneNumber != nil {
                                    contact.phoneNumbers.append(CNLabeledValue(label: CNLabelPhoneNumberiPhone, value: CNPhoneNumber(stringValue: detail.phoneNumber!)))
                                }
                                
                                // We own the home email :)
                                contact.emailAddresses.removeAll(where: { (email: CNLabeledValue<NSString>) in
                                    email.label == CNLabelHome
                                })
                                if detail.email != nil {
                                    contact.emailAddresses.append(CNLabeledValue(label: CNLabelHome, value: NSString(string: detail.email!)))
                                }
                                
                                let saveRequest = CNSaveRequest()
                                if contactOpt == nil {
                                    saveRequest.add(contact, toContainerWithIdentifier: nil)
                                } else {
                                    saveRequest.update(contact)
                                }
                                
                                do {
                                    try store.execute(saveRequest)
                                } catch {
                                    print("Error occur: \(error)")
                                }
                                
                            } catch (let error) {
                                print(error)
                            }
                        case .failure(let failure):
                            print(failure)
                        }
                    }
                }
            }
        }
    }
}
