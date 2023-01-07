//
//  CreateAccount.swift
//  Nevvi
//
//  Created by Tyler Cobb on 12/30/22.
//

import SwiftUI

struct CreateAccount: View {
    @State private var email = ""
    @State private var confirmationCode = ""
    @State private var password = ""
    @State private var error: AuthorizationStore.AuthorizationError?
    @State private var storeCredentials: Bool = false
    
    @State private var confirmationCodeEmail: String = ""
    @State private var showConfirmationCode: Bool
    
    @ObservedObject var authStore: AuthorizationStore
    
    var createAccountDisabled: Bool {
        self.email.isEmpty || self.password.isEmpty
    }
    
    var confirmAccountDisabled: Bool {
        self.email.isEmpty || self.confirmationCode.isEmpty
    }
    
    private var callback: (Authorization) -> Void
    
    init(authStore: AuthorizationStore, callback: @escaping (Authorization) -> Void) {
        self.authStore = authStore
        self.callback = callback
        self.showConfirmationCode = false
    }
    
    init(authStore: AuthorizationStore, callback: @escaping (Authorization) -> Void, showConfirmationCode: Bool) {
        self.authStore = authStore
        self.callback = callback
        self.showConfirmationCode = showConfirmationCode
    }
      
    var body: some View {
        NavigationView {
            VStack() {
                
                Spacer()
                
                Text("Welcome to Nevvi!")
                    .font(.largeTitle).foregroundColor(Color.white)
                    .padding([.top], 50)
                
                Text("Keep your contacts up to date!")
                    .font(.subheadline).foregroundColor(Color.white)
                    .padding([.top], 1)
                    .padding([.bottom], 50)
                
                if self.showConfirmationCode {
                    VStack(alignment: .center, spacing: 15) {
                        TextField("Email", text: self.$email)
                            .padding()
                            .keyboardType(.emailAddress)
                            .disableAutocorrection(true)
                            .autocapitalization(.none)
                            .background(.white)
                            .cornerRadius(10)
                        
                        TextField("Code", text: self.$confirmationCode)
                            .padding()
                            .keyboardType(.numberPad)
                            .background(.white)
                            .cornerRadius(10)
                        
                        Button(action: self.confirmAccount) {
                            Text("Confirm Account")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                        }
                        .disabled(self.confirmAccountDisabled)
                        .background(Color.green)
                        .frame(maxWidth: .infinity)
                        .cornerRadius(10.0)
                    }
                    .padding([.leading, .trailing], 27.5)
                } else {
                    VStack(alignment: .leading, spacing: 15) {
                        TextField("Email", text: self.$email)
                            .padding()
                            .keyboardType(.emailAddress)
                            .disableAutocorrection(true)
                            .autocapitalization(.none)
                            .background(.white)
                            .cornerRadius(10.0)
                        
                        SecureField("Password", text: self.$password)
                            .padding()
                            .disableAutocorrection(true)
                            .autocapitalization(.none)
                            .background(.white)
                            .cornerRadius(10.0)
                        
                        Button(action: self.createAccount) {
                            Text("Create Account")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                        }
                        .disabled(self.createAccountDisabled)
                        .background(Color.green)
                        .frame(maxWidth: .infinity)
                        .cornerRadius(10.0)
                    }
                    .padding([.leading, .trailing], 27.5)
                }
                
                if self.authStore.signingUp || self.authStore.confirming {
                    ProgressView().padding(20)
                }
                
                Spacer()

                Button(self.showConfirmationCode ? "Create account" : "Need to confirm an account?") {
                    self.showConfirmationCode = !self.showConfirmationCode
                }
                .padding()
                .foregroundColor(.white)
            }
            .autocapitalization(.none)
            .disabled(self.authStore.signingUp)
            .alert(item: self.$error) { error in
                if self.showConfirmationCode {
                    return Alert(title: Text("Failed to confirm account"), message: Text(error.localizedDescription))
                } else {
                    return Alert(title: Text("Failed to create account"), message: Text(error.localizedDescription))
                }
            }
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(UIColor(hexString: "#33897F")),
                        Color(UIColor(hexString: "#5293B8"))
                    ]),
                    startPoint: .top,
                    endPoint: .bottom).edgesIgnoringSafeArea(.all))
        }
    }
    
    func createAccount() {
        self.authStore.signUp(email: email, password: password) { (result: Result<AuthorizationStore.SignupResponse, AuthorizationStore.AuthorizationError>) in
            switch result {
            case .success(let response):
                self.confirmationCodeEmail = response.codeDeliveryDestination
                self.showConfirmationCode = true
            case .failure(let error):
                self.email = ""
                self.password = ""
                self.error = error
            }
        }
    }
    
    func confirmAccount() {
        self.authStore.confirmAccount(email: email, code: confirmationCode) { (result: Result<AuthorizationStore.ConfirmResponse, AuthorizationStore.AuthorizationError>) in
            switch result {
            case .success(_):
                if self.email.isEmpty == false && self.password.isEmpty == false {
                    self.signIn()
                }
                self.showConfirmationCode = false
            case .failure(let error):
                self.confirmationCode = ""
                self.error = error
            }
        }
    }
    
    func signIn() {
        self.authStore.login(email: email, password: password) { (result: Result<Authorization, AuthorizationStore.AuthorizationError>) in
            switch result {
            case .success(let authorization):
                self.callback(authorization)
            case .failure(let error):
                self.email = ""
                self.password = ""
                self.error = error
            }
        }
    }
}

struct CreateAccount_Previews: PreviewProvider {
    static var previews: some View {
        CreateAccount(authStore: AuthorizationStore(), callback: { authorization in
            print(authorization)
        }, showConfirmationCode: false)
    }
}
