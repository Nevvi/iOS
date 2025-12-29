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
    @State private var address = AddressViewModel()
    @State private var enterManually: Bool = false
    @State private var hasCoordinates: Bool = false
    @State private var coordinates: AddressCoordinates = AddressCoordinates()
    
    private var callback: (AddressViewModel) -> Void
    
    @StateObject private var addressSearchStore = AddressSearchStore()
    
    init(address: AddressViewModel, callback: @escaping (AddressViewModel) -> Void) {
        self.address = address
        self.callback = callback
    }
    
    // MARK: - Helper Views
    private func styledTextField(_ title: String, placeholder: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.primary)
            
            TextField(placeholder, text: text)
                .font(.system(size: 16, weight: .regular))
                .padding(16)
                .background(Color(.systemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color(.systemGray4), lineWidth: 1.5)
                )
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
        }
    }

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

                    self.address.street = "\(reversedGeoLocation.streetNumber) \(reversedGeoLocation.streetName)"
                    self.address.city = "\(reversedGeoLocation.city)"
                    self.address.state = "\(reversedGeoLocation.state)"
                    self.address.zipCode = "\(reversedGeoLocation.zipCode)"
                    self.address.unit = "" // make the user enter the unit manually
                    
                    addressSearchStore.searchTerm = self.address.street
                    
                    self.tryUpdatePin()
                }
            }
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // MARK: - Address Input Section
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("Address")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.primary)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Street Address")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.primary)
                        
                        TextField("111 Hollywood Ave", text: $addressSearchStore.searchTerm)
                            .font(.system(size: 16, weight: .regular))
                            .padding(16)
                            .background(Color(.systemBackground))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color(.systemGray4), lineWidth: 1.5)
                            )
                            .textInputAutocapitalization(.never)
                            .disableAutocorrection(true)
                    }
                }
                
                // MARK: - Search Suggestions
                if address.street != addressSearchStore.searchTerm {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Suggestions")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.primary)
                            .padding(.horizontal, 4)
                        
                        VStack(spacing: 6) {
                            ForEach(addressSearchStore.locationResults, id: \.self) { location in
                                Button(action: {
                                    reverseGeo(location: location)
                                }) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(location.title)
                                            .font(.system(size: 15, weight: .medium))
                                            .foregroundColor(.primary)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        
                                        Text(location.subtitle)
                                            .font(.system(size: 13))
                                            .foregroundColor(.secondary)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                    .padding(12)
                                    .background(Color(.systemGray6))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color(.systemGray4), lineWidth: 0.5)
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                } else {
                    // MARK: - Address Details Section
                    VStack(alignment: .leading, spacing: 16) {
                        // Unit and City Row
                        HStack(spacing: 16) {
                            styledTextField("Unit/Apartment", placeholder: "Apt 1A", text: $address.unit)
                                .frame(maxWidth: 120)
                            
                            styledTextField("City", placeholder: "Hollywood", text: $address.city)
                        }
                        
                        // State and ZIP Row
                        HStack(spacing: 16) {
                            styledTextField("State", placeholder: "CA", text: $address.state)
                                .frame(maxWidth: 120)
                            
                            styledTextField("ZIP Code", placeholder: "90210", text: $address.zipCode)
                                .frame(maxWidth: 120)
                            
                            Spacer()
                        }
                    }
                    
                    // MARK: - Map Preview Section
                    if hasCoordinates {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Location Preview")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.primary)
                            
                            Map(coordinateRegion: $coordinates.coordinates,
                                interactionModes: [.zoom], 
                                annotationItems: [coordinates]) { location in
                                MapPin(coordinate: CLLocationCoordinate2D(
                                    latitude: location.coordinates.center.latitude, 
                                    longitude: location.coordinates.center.longitude
                                ), tint: .red)
                            }
                            .frame(height: 200)
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color(.systemGray4), lineWidth: 1)
                            )
                        }
                    }
                    
                    // MARK: - Confirm Button
                    VStack(spacing: 0) {
                        Button(action: {
                            callback(address)
                        }) {
                            Text("Confirm Address")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, minHeight: 52)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .foregroundColor(ColorConstants.primary)
                                )
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.top, 24)
                    }
                }
            }
            .padding(20)
        }
        .background(Color(.systemBackground))
        .onAppear {
            addressSearchStore.searchTerm = address.street
            tryUpdatePin()
        }
    }
    
    private func tryUpdatePin() {
        let addressString = self.address.toString()
        if (addressString == "") {
            return
        }
        
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(addressString) { (placemarks, error) in
            guard let placemarks = placemarks,
            let coordinate = placemarks.first?.location?.coordinate else {
                print("no coordinates for address \(addressString)")
                self.coordinates = AddressCoordinates()
                self.hasCoordinates = false
                return
            }
            
            print("got coordinates for address \(addressString) - \(coordinate)")
            var location = MKCoordinateRegion()
            location.center.latitude = coordinate.latitude
            location.center.longitude = coordinate.longitude
            location.span.latitudeDelta = 0.01
            location.span.longitudeDelta = 0.01
            self.coordinates = AddressCoordinates(coordinates: location)
            self.hasCoordinates = true
        }
    }
}

struct AddressSearch_Previews: PreviewProvider {
    static let modelData = ModelData()
    
    static var previews: some View {
        AddressSearch(address: AddressViewModel().update(address: modelData.user.address)) { _ in }
    }
}
