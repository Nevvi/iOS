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
                }
            }
        }
    }


    @FocusState private var isFocused: Bool

    @State private var btnHover = false
    @State private var isBtnActive = false

    var body: some View {
        VStack(spacing: 0) {
            Text("Start typing your street address and you will see a list of possible matches.")
            
            TextField("Address", text: $addressSearchStore.searchTerm)
                .padding([.leading], 10)
                .padding([.top], 20)
            
            List {
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
            }.listRowSeparator(.visible)
            
            VStack(alignment: .leading) {
                Text("Address One")
                    .foregroundColor(.secondary)
                    .fontWeight(.light)
                    .font(.system(size: 14))
                
                TextField("111 Hollywood Ave", text: self.$accountStore.address.street)
                    .padding()
                    .overlay(RoundedRectangle(cornerRadius: 10.0).strokeBorder(Color.secondary, style: StrokeStyle(lineWidth: 1.0)))
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
            }
            .padding()
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Address Two")
                        .foregroundColor(.secondary)
                        .fontWeight(.light)
                        .font(.system(size: 14))
                    
                    TextField("Apt 1A", text: self.$accountStore.address.unit)
                        .padding()
                        .overlay(RoundedRectangle(cornerRadius: 10.0).strokeBorder(Color.secondary, style: StrokeStyle(lineWidth: 1.0)))
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
                    
                    TextField("Hollywood", text: self.$accountStore.address.city)
                        .padding()
                        .overlay(RoundedRectangle(cornerRadius: 10.0).strokeBorder(Color.secondary, style: StrokeStyle(lineWidth: 1.0)))
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
                    
                    TextField("CA", text: self.$accountStore.address.state)
                        .padding()
                        .overlay(RoundedRectangle(cornerRadius: 10.0).strokeBorder(Color.secondary, style: StrokeStyle(lineWidth: 1.0)))
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
                    
                    TextField("Zip Code", value: self.$accountStore.address.zipCode, formatter: NumberFormatter())
                        .padding()
                        .keyboardType(.numberPad)
                        .overlay(RoundedRectangle(cornerRadius: 10.0).strokeBorder(Color.secondary, style: StrokeStyle(lineWidth: 1.0)))
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                }
                .padding([.leading, .trailing])
                .padding([.bottom], 8)
            }
            
            Spacer()
            
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }, label: {
                Text("Done")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 50)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .foregroundColor(Color(UIColor(hexString: "#49C5B6")))
                    )
            })
            .shadow(radius: 10)
            .padding([.top], 20)

        }.padding()
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
