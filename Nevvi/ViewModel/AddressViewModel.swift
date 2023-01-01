//
//  File.swift
//  Nevvi
//
//  Created by Tyler Cobb on 1/1/23.
//

import Foundation

class AddressViewModel : ObservableObject {
    @Published var street: String = ""
    @Published var city: String = ""
    @Published var state: String = ""
    @Published var zipCode: Int = -1
    
    func update(address: Address) {
        self.street = address.street != nil ? address.street! : ""
        self.city = address.city != nil ? address.city! : ""
        self.state = address.state != nil ? address.state! : ""
        self.zipCode = address.zipCode != nil ? address.zipCode! : -1
    }
    
    func toModel() -> Address {
        return Address(street: self.street,
                       city: self.city,
                       state: self.state,
                       zipCode: self.zipCode)
    }
}
