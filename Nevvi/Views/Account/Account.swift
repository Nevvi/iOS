//
//  AccountView.swift
//  Nevvi
//
//  Created by Tyler Cobb on 12/29/22.
//

import SwiftUI

struct Account: View {
    @EnvironmentObject var accountStore: AccountStore
    @EnvironmentObject var authStore: AuthorizationStore
    
    @State private var phoneVerificationCode: String = ""
    @State private var showPhoneVerification: Bool = false
    @State private var showPicker: Bool = false
    @State private var newProfileImage = UIImage()
    
    @State private var showSettings: Bool = false
    @State private var showError: Bool = false
    @State private var error: Error? = nil

    var body: some View {
        NavigationView {
            VStack {
                VStack {
                    ZStack(alignment: .bottomTrailing) {
                        AsyncImage(url: URL(string: self.accountStore.profileImage), content: { image in
                            image.resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(maxWidth: 100, maxHeight: 100)
                                .clipShape(Circle())
                        }, placeholder: {
                            ProgressView()
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
                }.padding(30)
                
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
                    
                    TextField("111 Hollywood Ave", text: self.$accountStore.address.street)
                        .padding()
                        .overlay(RoundedRectangle(cornerRadius: 10.0).strokeBorder(Color.secondary, style: StrokeStyle(lineWidth: 1.0)))
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                }
                .padding([.leading, .trailing])
                .padding([.bottom], 8)
                
                VStack(alignment: .leading) {
                    DatePicker("Birthday", selection: self.$accountStore.birthday, displayedComponents: [.date]
                    )
                    .foregroundColor(.secondary)
                    .fontWeight(.light)
                    .font(.system(size: 14))
                }
                .padding()
                
                Button(action: {
                    self.accountStore.save { (result: Result<User, Error>) in
                        switch result {
                        case .failure(let error):
                            self.error = error
                            self.showError = true
                        case .success(_):
                            print("Success!")
                        }
                    }
                }, label: {
                    Text("Update")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .foregroundColor(self.accountStore.saving ? .gray : Color(UIColor(hexString: "#49C5B6")))
                        )
                })
                .padding([.top], 20)
                .padding([.bottom], 40)
                .disabled(self.accountStore.saving)
            }
            .padding(27.5)
            .sheet(isPresented: self.$showSettings) {
                VStack {
                    Text("Settings")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding([.top], 50)
                    
                    Spacer()
                    
                    Button(action: {
                        self.authStore.logout { (result: Result<Bool, Error>) in
                            switch result {
                            case .failure(let error):
                                self.error = error
                                self.showError = true
                            case .success(_):
                                self.accountStore.reset()
                            }
                        }
                    }, label: {
                        Text("Logout")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 40)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .foregroundColor(self.authStore.loggingOut ? .gray : Color(UIColor(hexString: "#49C5B6")))
                            )
                    })
                    
                    Spacer()
                }
                    .presentationDetents([.medium])
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
            .navigationTitle("My Account")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button {
                    self.showSettings = true
                } label: {
                    Image(systemName: "gearshape.fill")
                        .renderingMode(.template)
                        .foregroundColor(.black)
                }
            )
        }
    }

}

struct AccountView_Previews: PreviewProvider {
    static let modelData = ModelData()
    static let authStore = AuthorizationStore()
    static let accountStore = AccountStore(user: modelData.user)

    static var previews: some View {
        Account()
           .environmentObject(accountStore)
           .environmentObject(authStore)
    }
}
