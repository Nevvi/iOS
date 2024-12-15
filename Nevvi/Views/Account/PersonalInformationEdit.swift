//
//  AccountView.swift
//  Nevvi
//
//  Created by Tyler Cobb on 12/29/22.
//

import SwiftUI
import WrappingHStack


struct PersonalInformationEdit: View {
    @AppStorage("hasUpdatedProfileBefore.v1") var hasUpdatedBefore: Bool = false
    
    @EnvironmentObject var accountStore: AccountStore
    @EnvironmentObject var authStore: AuthorizationStore
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    @State private var showBirthdayPicker: Bool = false
    @State private var showAddressSearch: Bool = false
    @State private var showMailingAddressSearch: Bool = false
    @State private var showEmailVerification: Bool = false
    @State private var verificationCode: String = ""
    
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
                    
                    TextField("Role & company name", text: self.$accountStore.bio.max(50))
                        .bioStyle(size: 16, opacity: 1.0)
                        .textInputAutocapitalization(.sentences)
                        .disableAutocorrection(false)
                
                }.informationSection()
                
                VStack(alignment: .leading) {
                    TextField("Phone Number", text: self.$accountStore.phoneNumber)
                        .defaultStyle(size: 16, opacity: 1.0)
                        .keyboardType(.phonePad)
                        .disabled(true)
                    
                    Divider().padding([.vertical], 4)
                    
                    fieldPermissionGroupPicker(field: "phoneNumber")
                }.informationSection()
                
                VStack(alignment: .leading) {
                    Text("Email").personalInfoLabel()
                    
                    TextField("Email", text: self.$accountStore.email)
                        .defaultStyle(size: 16, opacity: 1.0)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                    
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
                    .contentShape(Rectangle())
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
                        
                        Image(systemName: "calendar")
                            .foregroundColor(ColorConstants.primary)
                    }
                    .padding([.vertical], 12)
                    .padding([.horizontal], 10)
                    .contentShape(Rectangle())
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .inset(by: 0.5)
                            .stroke(Color(red: 0, green: 0.07, blue: 0.17).opacity(0.12), lineWidth: 1)
                    )
                    .onTapGesture {
                        self.showBirthdayPicker.toggle()
                    }
                    
                    Divider().padding([.vertical], 4)
                    
                    fieldPermissionGroupPicker(field: "birthday")
                }.informationSection()
                
                if self.canSave {
                    Text("Update".uppercased())
                        .asPrimaryButton()
                        .opacity(self.accountStore.saving ? 0.7 : 1.0)
                        .onTapGesture {
                            self.update()
                        }
                }
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
        .onChange(of: self.accountStore.bio, perform: { newValue in
            self.tryToggle()
        })
        .onChange(of: self.accountStore.email, perform: { newValue in
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
        .sheet(isPresented: self.$showEmailVerification) {
            emailVerifySheet
                .presentationDetents([.fraction(0.40)])
        }
        .modifier(Popup(isPresented: !self.hasUpdatedBefore) {
            updateHelperSheet
        })
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(leading: cancelButton)
        .toolbar(content: {
            if self.canSave {
                updateAccountButton
            }
        })
    }
    
    var updateHelperSheet: some View {
        VStack(spacing: 24) {
            Image("AppLogo")
                .frame(width: 68, height: 68)
            
            Text("FYI")
                .defaultStyle(size: 16, opacity: 0.5)
            
            Text("You have complete control over who sees your info and what they can see once you connect.\n\nOther users you are not connected with can only see your name and bio.")
                .defaultStyle(size: 18, opacity: 0.7)
                .multilineTextAlignment(.center)

            Text("Dismiss")
                .asPrimaryButton()
                .onTapGesture {
                    UserDefaults.standard.set(true, forKey: "hasUpdatedProfileBefore.v1")
                }
                .padding(.top)
        }
        .frame(maxWidth: 250)
        .padding(32)
        .background(.white)
        .clipped()
        .shadow(color: Color(red: 0.06, green: 0.4, blue: 0.64)
            .opacity(0.16), radius: 30, x: 0, y: 4)
    }
    
    
    var cancelButton : some View { Button(action: {
        self.accountStore.resetChanges()
        self.presentationMode.wrappedValue.dismiss()
        }) {
            Text("Back")
                .foregroundColor(.gray)
        }
    }
    
    var datePickerSheet: some View {
        DynamicSheet(
            VStack(spacing: 8) {
                DatePicker("", selection: self.$accountStore.birthday, displayedComponents: [.date])
                    .datePickerStyle(.wheel)
                    .padding(.trailing)
                
                Text("Confirm")
                    .asPrimaryButton()
                    .onTapGesture {
                        self.showBirthdayPicker = false
                    }
            }.padding(.horizontal)
        )
    }
    
    var emailVerifySheet: some View {
        VStack(alignment: .center, spacing: 28) {
            Text("Please enter the code we sent to your updated email to confirm you as the owner.")
                .defaultStyle(size: 20, opacity: 1.0)
                .multilineTextAlignment(.center)
                        
            TextField("Code", text: self.$verificationCode)
                .frame(maxWidth: .infinity, alignment: .leading)
                .keyboardType(.numberPad)
                .padding()
                .overlay(RoundedRectangle(cornerRadius: 10.0).strokeBorder(Color.secondary, style: StrokeStyle(lineWidth: 1.0)))
                                                
            Button {
                self.accountStore.confirmEmail(code: self.verificationCode) { (result: Result<AccountStore.ConfirmResponse, Error>) in
                    switch result {
                    case .success(_):
                        self.accountStore.emailConfirmed = true
                        self.showEmailVerification = false
                        self.presentationMode.wrappedValue.dismiss()
                    case .failure(let error):
                        print("Something bad happened", error)
                    }
                }
            } label: {
                Text("Confirm")
                    .asPrimaryButton()
                    .opacity(self.verificationCode.count != 6 || self.accountStore.saving ? 0.5 : 1.0)
            }
            .disabled(self.verificationCode.count != 6 || self.accountStore.saving)
        }
        .padding()
        .disabled(self.accountStore.saving)
    }
    
    var updateAccountButton: some View {
        Button(action: {
            self.update()
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
        didPropChange(type: String.self, a: user.bio, b: self.accountStore.bio) ||
        didPropChange(type: String.self, a: user.email, b: self.accountStore.email) ||
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
    
    func update() -> Void {
        if self.accountStore.saving {
            return
        }
        
        
        let existingEmail = self.accountStore.user?.email
        
        self.accountStore.save { (result: Result<User, Error>) in
            switch result {
            case .failure(let error):
                print("Something bad happened", error)
            case .success(let user):
                self.tryToggle()
                if user.email != existingEmail {
                    self.accountStore.verifyEmail { (result: Result<AccountStore.VerifyResponse, Error>) in
                        switch result {
                        case .success(_):
                            self.showEmailVerification = true
                        case .failure(let error):
                            print("Something bad happened", error)
                        }
                    }
                } else {
                    self.presentationMode.wrappedValue.dismiss()
                }
            }
        }
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
