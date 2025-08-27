//
//  AddressCoordinates.swift
//  Nevvi
//
//  Created by Tyler Standal on 7/3/25.
//

import Foundation
import MapKit

class AddressCoordinates : Identifiable {
    var coordinates: MKCoordinateRegion
    
    init() {
        self.coordinates = MKCoordinateRegion()
    }
    
    init(coordinates: MKCoordinateRegion) {
        self.coordinates = coordinates
    }
}
