//
//  AccountView.swift
//  Nevvi
//
//  Created by Tyler Cobb on 12/29/22.
//

import SwiftUI

struct PersonalInformation: View {
    @EnvironmentObject var accountStore: AccountStore
    @EnvironmentObject var authStore: AuthorizationStore
    
    @State private var phoneVerificationCode: String = ""
    @State private var showPhoneVerification: Bool = false
    @State private var showPicker: Bool = false
    @State private var showBirthdayPicker: Bool = false
    @State private var showAddressSearch: Bool = false
    @State private var newProfileImage = UIImage()
    
    @State private var showSave: Bool = true
    @State private var canSave: Bool = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    VStack {
                        ZStack(alignment: .bottomTrailing) {
                            AsyncImage(url: URL(string: self.accountStore.profileImage), content: { image in
                                image.resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 80, height: 80)
                                    .clipShape(Circle())
                            }, placeholder: {
                                Image(systemName: "photo.circle")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 80, height: 80)
                                    .foregroundColor(.gray)
                                    .clipShape(Circle())
                            })
                            
                            Image(systemName: "plus")
                                .foregroundColor(.white)
                                .frame(width: 25, height: 25)
                                .background(Color.blue)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.white, lineWidth: 2))
                        }.onTapGesture {
                            self.showPicker = true
                        }
                        
                        Text(self.accountStore.email)
                            .foregroundColor(.secondary)
                            .font(.system(size: 14))
                    }.padding(10)
                    
                    VStack(alignment: .leading) {
                        Text("First Name")
                            .foregroundColor(.secondary)
                            .fontWeight(.light)
                            .font(.system(size: 14))
                        
                        TextField("Jane", text: self.$accountStore.firstName)
                            .padding()
                            .overlay(RoundedRectangle(cornerRadius: 10.0).strokeBorder(Color.secondary, style: StrokeStyle(lineWidth: 1.0)))
                            .textInputAutocapitalization(.never)
                            .disableAutocorrection(true)
                    }
                    .padding([.leading, .trailing])
                    .padding([.bottom], 8)
                    
                    VStack(alignment: .leading) {
                        Text("Last Name")
                            .foregroundColor(.secondary)
                            .fontWeight(.light)
                            .font(.system(size: 14))
                        
                        TextField("Doe", text: self.$accountStore.lastName)
                            .padding()
                            .overlay(RoundedRectangle(cornerRadius: 10.0).strokeBorder(Color.secondary, style: StrokeStyle(lineWidth: 1.0)))
                            .textInputAutocapitalization(.never)
                            .disableAutocorrection(true)
                    }
                    .padding([.leading, .trailing])
                    .padding([.bottom], 8)
                    
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Phone Number")
                                .foregroundColor(.secondary)
                                .fontWeight(.light)
                                .font(.system(size: 14))
                            
                            Spacer()
                            
                            if !self.accountStore.phoneNumber.isEmpty && !self.accountStore.phoneNumberConfirmed {
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
                        
                        TextField("", text: self.$accountStore.phoneNumber)
                            .padding()
                            .overlay(RoundedRectangle(cornerRadius: 10.0).strokeBorder(Color.secondary, style: StrokeStyle(lineWidth: 1.0)))
                            .textInputAutocapitalization(.never)
                            .disableAutocorrection(true)
                    }
                    .padding([.leading, .trailing])
                    .padding([.bottom], 8)
                    
                    VStack(alignment: .leading) {
                        Text("Street Address")
                            .foregroundColor(.secondary)
                            .fontWeight(.light)
                            .font(.system(size: 14))
                        
                        Text(self.accountStore.address.toString())
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .overlay(RoundedRectangle(cornerRadius: 10.0).strokeBorder(Color.secondary, style: StrokeStyle(lineWidth: 1.0))
                            )
                            .onTapGesture {
                                self.showAddressSearch = true
                            }
                    }
                    .padding([.leading, .trailing])
                    .padding([.bottom], 8)
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Birthday")
                                .foregroundColor(.secondary)
                                .fontWeight(.light)
                                .font(.system(size: 14))
                            
                            Text(self.accountStore.birthday.yyyyMMdd() != Date().yyyyMMdd() ?
                                 self.accountStore.birthday.yyyyMMdd() :
                                 "")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()
                                .overlay(RoundedRectangle(cornerRadius: 10.0).strokeBorder(Color.secondary, style: StrokeStyle(lineWidth: 1.0)))
                        }
                    }
                    .padding([.leading, .trailing])
                    .padding([.bottom], 8)
                    .onTapGesture {
                        self.showBirthdayPicker.toggle()
                    }
                        
                    
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
                .onChange(of: self.accountStore.address.street, perform: { newValue in
                    self.tryToggle()
                })
                .onChange(of: self.accountStore.address.unit, perform: { newValue in
                    self.tryToggle()
                })
                .onChange(of: self.accountStore.address.city, perform: { newValue in
                    self.tryToggle()
                })
                .onChange(of: self.accountStore.address.state, perform: { newValue in
                    self.tryToggle()
                })
                .onChange(of: self.accountStore.address.zipCode, perform: { newValue in
                    self.tryToggle()
                })
                .onChange(of: self.accountStore.birthday, perform: { newValue in
                    self.tryToggle()
                })
                .sheet(isPresented: self.$showBirthdayPicker) {
                    DatePicker("", selection: self.$accountStore.birthday, in: ...Date(), displayedComponents: [.date])
                        .datePickerStyle(.wheel)
                        .labelsHidden()
                        .padding()
                        .presentationDetents([.height(250)])
                }
                .sheet(isPresented: self.$showAddressSearch) {
                    AddressSearch()
                        .presentationDetents([.large])
                }
                .sheet(isPresented: self.$showPicker) {
                    ImagePicker(callback: { (image: UIImage) in
                        self.accountStore.uploadImage(image: image) { (result: Result<User, Error>) in
                            switch result {
                            case .failure(let error):
                                print("Something bad happened", error)
                            case .success(let user):
                                self.accountStore.update(user: user)
                            }
                        }
                    }, sourceType: .photoLibrary)
                }
                .sheet(isPresented: self.$showPhoneVerification) {
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
                .navigationBarTitleDisplayMode(.inline)
            }
        }
        .toolbar(content: {
            if self.canSave {
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
        })
    }
    
    func tryToggle() {
        guard let user = self.accountStore.user else {
            return
        }
        
        let didChange = didPropChange(type: String.self, a: user.firstName, b: self.accountStore.firstName) ||
        didPropChange(type: String.self, a: user.lastName, b: self.accountStore.lastName) ||
        didPropChange(type: String.self, a: user.phoneNumber, b: self.accountStore.phoneNumber) ||
        didPropChange(type: String.self, a: user.address.street, b: self.accountStore.address.street) ||
        didPropChange(type: String.self, a: user.address.unit, b: self.accountStore.address.unit) ||
        didPropChange(type: String.self, a: user.address.city, b: self.accountStore.address.city) ||
        didPropChange(type: String.self, a: user.address.state, b: self.accountStore.address.state) ||
        didPropChange(type: Int.self, a: user.address.zipCode, b: self.accountStore.address.zipCode) ||
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
