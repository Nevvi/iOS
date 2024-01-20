//
//  AccountView.swift
//  Nevvi
//
//  Created by Tyler Cobb on 12/29/22.
//

import SwiftUI
import WrappingHStack


struct PersonalInformationEdit: View {
    @EnvironmentObject var accountStore: AccountStore
    @EnvironmentObject var authStore: AuthorizationStore
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @State private var phoneVerificationCode: String = ""
    @State private var showPhoneVerification: Bool = false
    @State private var showBirthdayPicker: Bool = false
    @State private var showAddressSearch: Bool = false
    @State private var showMailingAddressSearch: Bool = false
    @State private var newProfileImage = UIImage()
    
    @State private var canSave: Bool = false
    
    private var sameMailingAddress: Binding<Bool> { Binding (
        get: { self.accountStore.mailingAddress.toString() == self.accountStore.address.toString() },
        set: {
            if !$0 {
                self.accountStore.mailingAddress = AddressViewModel()
            } else {
                self.accountStore.mailingAddress = self.accountStore.mailingAddress.update(address: self.accountStore.address.toModel())
            }
            self.tryToggle()
        }
    )}
    
    private var isBirthdayEmpty: Bool {
        return self.accountStore.birthday.yyyyMMdd() == Date().yyyyMMdd()
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                HStack {
                    Spacer()
                    ProfileImageSelector(height: 108, width: 108)
                    Spacer()
                }
                .padding(.bottom)
                
                VStack(alignment: .leading) {
                    Text("Name").personalInfoLabel()
                    
                    TextField("First Name", text: self.$accountStore.firstName)
                        .defaultStyle(size: 16, opacity: 1.0)
                    
                    TextField("Last Name", text: self.$accountStore.lastName)
                        .defaultStyle(size: 16, opacity: 1.0)
                }.informationSection()
                
                VStack(alignment: .leading) {
                    Text("Bio").personalInfoLabel()
                    
                    TextField("Role & company name", text: self.$accountStore.bio)
                        .bioStyle(size: 16, opacity: 1.0)
                }.informationSection()
                
                VStack(alignment: .leading) {
                    phoneVerificationLabel
                    
                    TextField("Phone Number", text: self.$accountStore.phoneNumber)
                        .defaultStyle(size: 16, opacity: 1.0)
                    
                    Divider().padding([.vertical], 4)
                    
                    fieldPermissionGroupPicker(field: "phoneNumber")
                }.informationSection()
                
                VStack(alignment: .leading) {
                    Text("Email").personalInfoLabel()
                    
                    TextField("Email", text: self.$accountStore.email)
                        .defaultStyle(size: 16, opacity: 1.0)
                    
                    Divider().padding([.vertical], 4)
                    
                    fieldPermissionGroupPicker(field: "email")
                }.informationSection()
                
                VStack(alignment: .leading) {
                    Text("Address").personalInfoLabel()
                    
                    HStack(alignment: self.accountStore.address.isEmpty ? .center : .top, spacing: 8) {
                        Button {
                            self.accountStore.address = AddressViewModel()
                        } label: {
                            Image(systemName: "minus.circle")
                                .foregroundColor(Color.red)
                                .opacity(self.accountStore.address.isEmpty ? 0.5 : 1.0)
                        }
                        .disabled(self.accountStore.address.isEmpty)
                        .buttonStyle(.borderless)
                        
                        Text(self.accountStore.address.isEmpty ? "" : self.accountStore.address.toString())
                            .defaultStyle(size: 16, opacity: 1.0)
                            .onTapGesture {
                                self.showAddressSearch = true
                            }
                        
                        Spacer()
                        
                        Text("Home").asPrimaryBadge()
                    }
                    .padding([.vertical], 12)
                    .padding([.horizontal], 10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .inset(by: 0.5)
                            .stroke(Color(red: 0, green: 0.07, blue: 0.17).opacity(0.12), lineWidth: 1)
                    )
                    .onTapGesture {
                        if self.accountStore.address.isEmpty {
                            self.showAddressSearch = true
                        }
                    }
                    
                    Divider().padding([.vertical], 4)
                    
                    fieldPermissionGroupPicker(field: "address")
                }.informationSection()
                
                VStack(alignment: .leading) {
                    Text("Birthday")
                        .personalInfoLabel()
                    
                    HStack(alignment: .top) {
                        Button {
                            self.accountStore.birthday = Date()
                        } label: {
                            Image(systemName: "minus.circle")
                                .foregroundColor(Color.red)
                                .opacity(self.isBirthdayEmpty ? 0.5 : 1.0)
                        }
                        .disabled(self.isBirthdayEmpty)
                        .buttonStyle(.borderless)
                        
                        Text(self.isBirthdayEmpty ? "" : self.accountStore.birthday.toString())
                            .defaultStyle(size: 16, opacity: 1.0)
                        
                        Spacer()
                        
                        Button {
                            self.showBirthdayPicker.toggle()
                        } label: {
                            Image(systemName: "calendar")
                        }.buttonStyle(.borderless)
                    }
                    .padding([.vertical], 12)
                    .padding([.horizontal], 10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .inset(by: 0.5)
                            .stroke(Color(red: 0, green: 0.07, blue: 0.17).opacity(0.12), lineWidth: 1)
                    )
                    
                    Divider().padding([.vertical], 4)
                    
                    fieldPermissionGroupPicker(field: "birthday")
                }.informationSection()
            }
            .padding()
        }
        .background(ColorConstants.background)
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
                self.updateAddress(address: address, isMailing: false)
                self.showAddressSearch = false
            }).presentationDetents([.large])
        }
        .sheet(isPresented: self.$showMailingAddressSearch) {
            AddressSearch(address: self.accountStore.mailingAddress, callback: { address in
                self.updateAddress(address: address, isMailing: true)
                self.showMailingAddressSearch = false
            }).presentationDetents([.large])
        }
        .sheet(isPresented: self.$showPhoneVerification) {
            phoneVerificationSheet
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: cancelButton)
        .toolbar(content: {
            if self.canSave {
                updateAccountButton
            }
        })
    }
    
    var cancelButton : some View { Button(action: {
        self.presentationMode.wrappedValue.dismiss()
        }) {
            Text("Back")
                .foregroundColor(.gray)
        }
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
                .fontWeight(.bold)
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
    
    func fieldPermissionGroupPicker(field: String) -> some View {
        FieldPermissionGroupPicker(fieldName: field, permissionGroups: self.accountStore.permissionGroups.map { $0.copy() })
    }

    
    func updateAddress(address: AddressViewModel, isMailing: Bool) {
        if isMailing {
            self.accountStore.mailingAddress = address
        } else {
            self.accountStore.address = address
        }
        self.tryToggle()
    }
    
    func tryToggle() {
        guard let user = self.accountStore.user else {
            return
        }
        
        let addressModel = self.accountStore.address.toModel()
        let mailingAddressModel = self.accountStore.mailingAddress.toModel()
        
        let didChange = didPropChange(type: String.self, a: user.firstName, b: self.accountStore.firstName) ||
        didPropChange(type: String.self, a: user.lastName, b: self.accountStore.lastName) ||
        didPropChange(type: String.self, a: user.phoneNumber, b: self.accountStore.phoneNumber) ||
        didPropChange(type: String.self, a: user.address.street, b: addressModel.street) ||
        didPropChange(type: String.self, a: user.address.unit, b: addressModel.unit) ||
        didPropChange(type: String.self, a: user.address.city, b: addressModel.city) ||
        didPropChange(type: String.self, a: user.address.state, b: addressModel.state) ||
        didPropChange(type: String.self, a: user.address.zipCode, b: addressModel.zipCode) ||
        didPropChange(type: String.self, a: user.mailingAddress.street, b: mailingAddressModel.street) ||
        didPropChange(type: String.self, a: user.mailingAddress.unit, b: mailingAddressModel.unit) ||
        didPropChange(type: String.self, a: user.mailingAddress.city, b: mailingAddressModel.city) ||
        didPropChange(type: String.self, a: user.mailingAddress.state, b: mailingAddressModel.state) ||
        didPropChange(type: String.self, a: user.mailingAddress.zipCode, b: mailingAddressModel.zipCode) ||
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

struct PersonalInformationEdit_Previews: PreviewProvider {
    static let modelData = ModelData()
    static let authStore = AuthorizationStore()
    static let accountStore = AccountStore(user: modelData.user)

    static var previews: some View {
        PersonalInformationEdit()
            .environmentObject(accountStore)
            .environmentObject(authStore)
    }
}
