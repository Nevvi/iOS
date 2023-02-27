//
//  AccountView.swift
//  Nevvi
//
//  Created by Tyler Cobb on 12/29/22.
//

import SwiftUI

extension VStack {
    func personalInfoStyle() -> some View {
        return self
            .padding([.leading, .trailing])
            .padding([.bottom], 12)
    }
}

struct PersonalInformation: View {
    @EnvironmentObject var accountStore: AccountStore
    @EnvironmentObject var authStore: AuthorizationStore
    
    @State private var phoneVerificationCode: String = ""
    @State private var showPhoneVerification: Bool = false
    @State private var showBirthdayPicker: Bool = false
    @State private var showAddressSearch: Bool = false
    @State private var newProfileImage = UIImage()
    
    @State private var canSave: Bool = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    VStack {
                        ProfileImageSelector(height: 80, width: 80)
                        
                        Text(self.accountStore.email)
                            .foregroundColor(.secondary)
                            .font(.system(size: 14))
                    }.padding(10)
                    
                    VStack(alignment: .leading) {
                        Text("First Name")
                            .personalInfoLabel()
                        
                        TextField("Jane", text: self.$accountStore.firstName)
                            .personalInfoStyle()
                    }.personalInfoStyle()
                    
                    VStack(alignment: .leading) {
                        Text("Last Name")
                            .personalInfoLabel()
                        
                        TextField("Doe", text: self.$accountStore.lastName)
                            .personalInfoStyle()
                    }.personalInfoStyle()
                    
                    VStack(alignment: .leading) {
                        phoneVerificationLabel
                        
                        TextField("", text: self.$accountStore.phoneNumber)
                            .personalInfoStyle()
                    }.personalInfoStyle()
                    
                    VStack(alignment: .leading) {
                        Text("Street Address")
                            .personalInfoLabel()
                        
                        ZStack {
                            RoundedRectangle(cornerRadius: 10.0).strokeBorder(Color.secondary, style: StrokeStyle(lineWidth: 1.0))
                            
                            Text(self.accountStore.address.street != "" ? self.accountStore.address.toString() : "")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(16)
                        }
                        .contentShape(RoundedRectangle(cornerRadius: 10.0))
                        .onTapGesture {
                            self.showAddressSearch = true
                        }
                    }
                    .personalInfoStyle()
                    
                    VStack(alignment: .leading) {
                        Text("Birthday")
                            .personalInfoLabel()
                        
                        ZStack {
                            RoundedRectangle(cornerRadius: 10.0).strokeBorder(Color.secondary, style: StrokeStyle(lineWidth: 1.0))
                            
                            Text(self.accountStore.birthday.yyyyMMdd() != Date().yyyyMMdd() ?
                                 self.accountStore.birthday.toString() :
                                 "")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(14)
                        }
                        .contentShape(RoundedRectangle(cornerRadius: 10.0))
                        .onTapGesture {
                            self.showBirthdayPicker.toggle()
                        }
                    }
                    .personalInfoStyle()
                        
                    Spacer()
                }
                .onChange(of: self.accountStore.firstName, perform: { newValue in
                    self.tryToggle()
                })
                .onChange(of: self.accountStore.lastName, perform: { newValue in
                    self.tryToggle()
                })
                .onChange(of: self.accountStore.phoneNumber, perform: { newValue in
                    self.tryToggle()
                })
                .onChange(of: self.accountStore.birthday, perform: { newValue in
                    self.tryToggle()
                })
                .sheet(isPresented: self.$showBirthdayPicker) {
                    datePickerSheet
                }
                .sheet(isPresented: self.$showAddressSearch) {
                    AddressSearch(address: self.accountStore.address, callback: { address in
                        self.updateAddress(address: address)
                        self.showAddressSearch = false
                    }).presentationDetents([.large])
                }
                .sheet(isPresented: self.$showPhoneVerification) {
                    phoneVerificationSheet
                }
            }
        }
        .toolbar(content: {
            if self.canSave {
                updateAccountButton
            }
        })
    }
    
    var phoneVerificationLabel: some View {
        HStack {
            Text("Phone Number")
                .personalInfoLabel()
            
            Spacer()
            
            if !self.accountStore.phoneNumber.isEmpty && !self.accountStore.phoneNumberConfirmed && self.accountStore.phoneNumber == self.accountStore.user?.phoneNumber {
                Button {
                    self.accountStore.verifyPhone { (result: Result<AccountStore.VerifyPhoneResponse, Error>) in
                        switch result {
                        case .success(_):
                            self.showPhoneVerification = true
                        case .failure(let error):
                            print("Something bad happened", error)
                        }
                    }
                } label: {
                    Text("Verify")
                }
                .fontWeight(.light)
                .font(.system(size: 14))
            }
        }
    }
    
    var phoneVerificationSheet: some View {
        VStack(alignment: .center) {
            Text("Please enter the confirmation code we texted to you")
                .multilineTextAlignment(.center)
                .padding([.top], 50)
            
            Spacer()
            
            TextField("Code", text: self.$phoneVerificationCode)
                .frame(maxWidth: .infinity, alignment: .leading)
                .keyboardType(.numberPad)
                .padding()
                .overlay(RoundedRectangle(cornerRadius: 10.0).strokeBorder(Color.secondary, style: StrokeStyle(lineWidth: 1.0)))
            
            Spacer()
            
            Button {
                self.accountStore.confirmPhone(code: self.phoneVerificationCode) { (result: Result<AccountStore.ConfirmPhoneResponse, Error>) in
                    switch result {
                    case .success(_):
                        // TODO - load this new value more dynamically instead of hard code?
                        self.accountStore.phoneNumberConfirmed = true
                        self.showPhoneVerification = false
                    case .failure(let error):
                        print("Something bad happened", error)
                    }
                }
            } label: {
                if self.accountStore.saving {
                    ProgressView()
                        .padding()
                        .frame(width: 300, height: 50)
                        .background(Color.green)
                        .cornerRadius(15.0)
                } else {
                    Text("Confirm Phone")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: 300, height: 50)
                        .background(self.phoneVerificationCode.count != 6 ? .gray : Color.green)
                        .cornerRadius(15.0)
                }
            }
            .disabled(self.phoneVerificationCode.count != 6)
            .padding()
        }
        .padding(40)
        .disabled(self.accountStore.saving)
        .presentationDetents([.medium])
    }
    
    var datePickerSheet: some View {
        DatePicker("", selection: self.$accountStore.birthday, in: ...Date(), displayedComponents: [.date])
            .datePickerStyle(.wheel)
            .labelsHidden()
            .padding()
            .presentationDetents([.height(250)])
    }
    
    var updateAccountButton: some View {
        Button(action: {
            self.accountStore.save { (result: Result<User, Error>) in
                switch result {
                case .failure(let error):
                    print("Something bad happened", error)
                case .success(_):
                    self.tryToggle()
                }
            }
        }, label: {
            Text("Update")
        })
        .disabled(self.accountStore.saving)
    }
    
    func updateAddress(address: AddressViewModel) {
        self.accountStore.address = address
        self.tryToggle()
    }
    
    func tryToggle() {
        guard let user = self.accountStore.user else {
            return
        }
        
        let addressModel = self.accountStore.address.toModel()
        let didChange = didPropChange(type: String.self, a: user.firstName, b: self.accountStore.firstName) ||
        didPropChange(type: String.self, a: user.lastName, b: self.accountStore.lastName) ||
        didPropChange(type: String.self, a: user.phoneNumber, b: self.accountStore.phoneNumber) ||
        didPropChange(type: String.self, a: user.address.street, b: addressModel.street) ||
        didPropChange(type: String.self, a: user.address.unit, b: addressModel.unit) ||
        didPropChange(type: String.self, a: user.address.city, b: addressModel.city) ||
        didPropChange(type: String.self, a: user.address.state, b: addressModel.state) ||
        didPropChange(type: Int.self, a: user.address.zipCode, b: addressModel.zipCode) ||
        didPropChange(type: Date.self, a: user.birthday, b: self.accountStore.birthday)
        
        if (!self.canSave && didChange) || (self.canSave && !didChange) {
            withAnimation {
                self.canSave.toggle()
            }
        }
    }
    
    func didPropChange<T: Equatable>(type: T.Type, a: Any?, b: Any?) -> Bool {
        let a = a as? T
        let b = b as? T
        
        if T.self == String.self {
            if (a as? String == "" || a == nil) && (b as? String == "" || b == nil) {
                return false
            }
        }

        return a != b
    }

}

struct PersonalInformation_Previews: PreviewProvider {
    static let modelData = ModelData()
    static let authStore = AuthorizationStore()
    static let accountStore = AccountStore(user: modelData.user)

    static var previews: some View {
        VStack {
            PersonalInformation()
                .environmentObject(accountStore)
                .environmentObject(authStore)
        }
    }
}
