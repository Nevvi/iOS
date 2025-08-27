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

    @State private var btnHover = false
    @State private var isBtnActive = false

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading) {
                HStack {
                    Text("Address")
                        .foregroundColor(.secondary)
                        .fontWeight(.light)
                        .font(.system(size: 14))
                    
                    Toggle(isOn: self.$enterManually) {
                        Text("Manual Entry")
                            .foregroundColor(.secondary)
                            .fontWeight(.light)
                            .font(.system(size: 14))
                            .frame(maxWidth: .infinity, alignment: .trailing)
                              
                    }
                }
                
                TextField("111 Hollywood Ave", text: self.enterManually ? self.$address.street : self.$addressSearchStore.searchTerm)
                    .font(.system(size: 16, weight: .regular))
                    .padding(14)
                    .background(Color.white)
                    .cornerRadius(12)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(ColorConstants.secondary, lineWidth: 1))
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
            }
            .padding()
            
            if self.address.street != addressSearchStore.searchTerm && !self.enterManually {
                ScrollView {
                    VStack(alignment: .leading) {
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
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding([.leading])
                            .padding([.bottom], 5)
                        }
                    }
                }
            } else {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Address Two")
                            .foregroundColor(.secondary)
                            .fontWeight(.light)
                            .font(.system(size: 14))
    
                        TextField("Apt 1A", text: self.$address.unit)
                            .font(.system(size: 16, weight: .regular))
                            .padding(14)
                            .background(Color.white)
                            .cornerRadius(12)
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(ColorConstants.secondary, lineWidth: 1))
                            .textInputAutocapitalization(.never)
                            .disableAutocorrection(true)
                    }
                    .padding([.leading, .trailing])
                    .padding([.bottom], 8)
    
                    VStack(alignment: .leading) {
                        Text("City")
                            .foregroundColor(.secondary)
                            .fontWeight(.light)
                            .font(.system(size: 14))
    
                        TextField("Hollywood", text: self.$address.city)
                            .font(.system(size: 16, weight: .regular))
                            .padding(14)
                            .background(Color.white)
                            .cornerRadius(12)
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(ColorConstants.secondary, lineWidth: 1))
                            .textInputAutocapitalization(.never)
                            .disableAutocorrection(true)
                    }
                    .padding([.leading, .trailing])
                    .padding([.bottom], 8)
                }
    
                HStack {
                    VStack(alignment: .leading) {
                        Text("State")
                            .foregroundColor(.secondary)
                            .fontWeight(.light)
                            .font(.system(size: 14))
    
                        TextField("CA", text: self.$address.state)
                            .font(.system(size: 16, weight: .regular))
                            .padding(14)
                            .background(Color.white)
                            .cornerRadius(12)
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(ColorConstants.secondary, lineWidth: 1))
                            .textInputAutocapitalization(.never)
                            .disableAutocorrection(true)
                    }
                    .padding([.leading, .trailing])
                    .padding([.bottom], 8)
    
                    VStack(alignment: .leading) {
                        Text("Zip Code")
                            .foregroundColor(.secondary)
                            .fontWeight(.light)
                            .font(.system(size: 14))
    
                        TextField("Zip Code", text: self.$address.zipCode)
                            .font(.system(size: 16, weight: .regular))
                            .padding(14)
                            .background(Color.white)
                            .cornerRadius(12)
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(ColorConstants.secondary, lineWidth: 1))
                            .textInputAutocapitalization(.never)
                            .disableAutocorrection(true)
                    }
                    .padding([.leading, .trailing])
                    .padding([.bottom], 8)
                }
                
                if (self.hasCoordinates && !self.enterManually) {
                    Map(coordinateRegion: self.$coordinates.coordinates,
                        interactionModes: [.zoom], annotationItems: [self.coordinates],
                        annotationContent: { location in
                        MapPin(coordinate: CLLocationCoordinate2D(latitude: location.coordinates.center.latitude, longitude: location.coordinates.center.longitude), tint: .red)
                    })
                    .padding()
                }
                
                Spacer()
                
                Button(action: {
                    self.callback(self.address)
                }, label: {
                    Text("Confirm")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 24)
                                .foregroundColor(ColorConstants.primary)
                        )
                })
                .padding([.top], 20)
            }
        }
        .padding()
        .onAppear {
            self.addressSearchStore.searchTerm = self.address.street
            self.tryUpdatePin()
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
