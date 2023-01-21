//
//  ContactStore.swift
//  Nevvi
//
//  Created by Tyler Cobb on 1/5/23.
//

import Contacts

class ContactStore: ObservableObject {
    var authorization: Authorization? = nil
    
    @Published var error: Swift.Error?
    
    private func connectionUrl(connectionId: String) throws -> URL {
        if (self.authorization == nil) {
            throw GenericError("Not logged in")
        }
        
        let userId: String? = self.authorization?.id
        return URL(string: "https://api.development.nevvi.net/user/v1/users/\(userId!)/connections/\(connectionId)")!
    }
    
    func updateConnection(connectionId: String, callback: @escaping (Result<Connection, Error>) -> Void) {
        do {
            let idToken: String? = self.authorization?.idToken
            let request = UpdateRequest(inSync: true)
            URLSession.shared.patchData(for: try self.connectionUrl(connectionId: connectionId), for: request, for: "Bearer \(idToken!)") { (result: Result<Connection, Error>) in
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
    
    func syncContacts(connections: [Connection], callback: @escaping () -> Void) {
        let store = CNContactStore()
        let dispatchGroup = DispatchGroup()
        
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
                                                      
                        // We own the mobile number :)
                        contact.phoneNumbers.removeAll(where: { (phoneNumber: CNLabeledValue<CNPhoneNumber>) in
                            phoneNumber.label == CNLabelPhoneNumberMobile
                        })
                        if detail.phoneNumber != nil {
                            contact.phoneNumbers.append(CNLabeledValue(label: CNLabelPhoneNumberMobile, value: CNPhoneNumber(stringValue: detail.phoneNumber!)))
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
                            // Only update name if creating this contact for the first time
                            contact.givenName = detail.firstName
                            contact.familyName = detail.lastName
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
                
                self.updateConnection(connectionId: connection.id) {_ in
                    dispatchGroup.leave()
                }
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            print("Done syncing \(connections.count) contacts")
            callback()
        }
    }
    
    struct UpdateRequest: Encodable {
        var inSync: Bool
    }
}
