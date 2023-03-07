//
//  File.swift
//  Nevvi
//
//  Created by Tyler Cobb on 1/1/23.
//

import Foundation

class AddressViewModel : ObservableObject {
    @Published var street: String = ""
    @Published var unit: String = ""
    @Published var city: String = ""
    @Published var state: String = ""
    @Published var zipCode: String = ""
    
    var isEmpty: Bool {
        return self.street.isEmpty && self.city.isEmpty && self.state.isEmpty
    }
    
    func update(address: Address) -> AddressViewModel {
        self.street = address.street != nil ? address.street! : ""
        self.unit = address.unit != nil ? address.unit! : ""
        self.city = address.city != nil ? address.city! : ""
        self.state = address.state != nil ? address.state! : ""
        self.zipCode = address.zipCode != nil ? address.zipCode! : ""
        return self
    }
    
    func toModel() -> Address {
        return Address(street: self.street != "" ? self.street : nil,
                       unit: self.unit != "" ? self.unit : nil,
                       city: self.city != "" ? self.city : nil,
                       state: self.state != "" ? self.state : nil,
                       zipCode: self.zipCode != "" ? self.zipCode : nil)
    }
    
    func toString() -> String {
        if self.street == "" {
            return ""
        }
        
        return "\(self.street)\(self.unit != "" ? " \(self.unit)" : "" )\n\(self.city), \(self.state)\n\(self.zipCode)"
    }
}
