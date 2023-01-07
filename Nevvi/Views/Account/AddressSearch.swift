//
//  AddressSearch.swift
//  Nevvi
//
//  Created by Tyler Cobb on 1/7/23.
//

import SwiftUI
import Combine
import CoreLocation
import MapKit

struct AddressSearch: View {
    @Environment(\.presentationMode) private var presentationMode
    @EnvironmentObject var accountStore: AccountStore
    @StateObject private var addressSearchStore = AddressSearchStore()

    func reverseGeo(location: MKLocalSearchCompletion) {
        let searchRequest = MKLocalSearch.Request(completion: location)
        let search = MKLocalSearch(request: searchRequest)
        var coordinateK : CLLocationCoordinate2D?
        search.start { (response, error) in
            if error == nil, let coordinate = response?.mapItems.first?.placemark.coordinate {
                coordinateK = coordinate
            }

            if let c = coordinateK {
                let location = CLLocation(latitude: c.latitude, longitude: c.longitude)
                CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
                    guard let placemark = placemarks?.first else {
                        let errorString = error?.localizedDescription ?? "Unexpected Error"
                        print("Unable to reverse geocode the given location. Error: \(errorString)")
                        return
                    }

                    let reversedGeoLocation = ReversedGeoLocation(with: placemark)

                    self.accountStore.address.street = "\(reversedGeoLocation.streetNumber) \(reversedGeoLocation.streetName)"
                    self.accountStore.address.city = "\(reversedGeoLocation.city)"
                    self.accountStore.address.state = "\(reversedGeoLocation.state)"
                    self.accountStore.address.zipCode = Int(reversedGeoLocation.zipCode)!
                    addressSearchStore.searchTerm = self.accountStore.address.street
                    isFocused = false
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
    }


    @FocusState private var isFocused: Bool

    @State private var btnHover = false
    @State private var isBtnActive = false

    var body: some View {
        VStack {
            List {
                Section {
                    Text("Start typing your street address and you will see a list of possible matches.")
                }
                
                Section {
                    TextField("Address", text: $addressSearchStore.searchTerm)

                    if self.accountStore.address.street != addressSearchStore.searchTerm && isFocused == false {
                        ForEach(addressSearchStore.locationResults, id: \.self) { location in
                            Button {
                                reverseGeo(location: location)
                            } label: {
                                VStack(alignment: .leading) {
                                    Text(location.title)
                                    Text(location.subtitle)
                                        .font(.system(.caption))
                                }
                            }
                        }
                    }
                }
                .listRowSeparator(.visible)
            }
        }
    }
}

struct AddressSearch_Previews: PreviewProvider {
    static let modelData = ModelData()
    static let accountStore = AccountStore(user: modelData.user)
    
    static var previews: some View {
        AddressSearch()
            .environmentObject(accountStore)
    }
}
