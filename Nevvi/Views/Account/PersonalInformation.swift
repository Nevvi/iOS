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
    @State private var showError: Bool = false
    @State private var error: Error? = nil
    
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
                                            self.error = error
                                            self.showError = true
                                        }
                                    }
                                } label: {
                                    Text("Verify")
                                }
                                .fontWeight(.light)
                                .font(.system(size: 14))
                            }
                        }
                        
                        TextField("555-555-5555", text: self.$accountStore.phoneNumber)
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
                            
                            Text(self.accountStore.birthday.yyyyMMdd())
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
                                self.error = error
                                self.showError = true
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
                                    self.error = error
                                    self.showError = true
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
                .alert(isPresented: self.$showError) {
                    Alert(title: Text("Something went wrong"), message: Text(self.error!.localizedDescription))
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
                            self.error = error
                            self.showError = true
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
        
        let didChange = user.firstName != self.accountStore.firstName ||
        user.lastName != self.accountStore.lastName ||
        user.phoneNumber != self.accountStore.phoneNumber ||
        user.address.street != self.accountStore.address.street ||
        user.birthday != self.accountStore.birthday
        
        if (!self.canSave && didChange) || (self.canSave && !didChange) {
            withAnimation {
                self.canSave.toggle()
            }
        }
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
