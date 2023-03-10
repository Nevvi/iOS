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
    
    var passwordContainsUppercase: Bool {
        !self.password.isEmpty && self.password.contains(where: { char in
            char.isUppercase
        })
    }
    
    var passwordContainsLowercase: Bool {
        !self.password.isEmpty && self.password.contains(where: { char in
            char.isLowercase
        })
    }
    
    var passwordContainsNumber: Bool {
        !self.password.isEmpty && self.password.contains(where: { char in
            char.isNumber
        })
    }
    
    var passwordContainsSpecialChar: Bool {
        !self.password.isEmpty && self.password.range(of: ".*[^A-Za-z0-9].*", options: .regularExpression) != nil
    }
    
    var passwordMinimumLength: Bool {
        !self.password.isEmpty && self.password.count >= 8
    }
    
    var createAccountDisabled: Bool {
        self.email.isEmpty ||
        self.password.isEmpty ||
        self.authStore.signingUp ||
        !self.passwordContainsUppercase ||
        !self.passwordContainsLowercase ||
        !self.passwordContainsSpecialChar ||
        !self.passwordContainsNumber ||
        !self.passwordMinimumLength
    }
    
    var confirmAccountDisabled: Bool {
        self.email.isEmpty || self.confirmationCode.isEmpty || self.authStore.confirming || self.authStore.loggingIn
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
        VStack() {
            Spacer()
            
            Text(self.showConfirmationCode ? "Confirm your account" : "Welcome to Nevvi!")
                .font(.largeTitle).foregroundColor(Color.white)
            
            Text(self.showConfirmationCode ? "Enter the code sent to your email" : "Keep your contacts up to date!")
                .font(.subheadline).foregroundColor(Color.white)
                .padding([.top], 1)
                .padding([.bottom], 50)
            
            if self.showConfirmationCode {
                confirmationCodeView
            } else {
                createAccountView
            }

            Button(self.showConfirmationCode ? "Create account" : "Need to confirm an account?") {
                self.showConfirmationCode = !self.showConfirmationCode
            }
            .padding([.top, .bottom], 30)
            .foregroundColor(.white)
        }
        .autocapitalization(.none)
        .disabled(self.authStore.signingUp)
        .background(BackgroundGradient())
        .alert(item: self.$error) { error in
            if self.showConfirmationCode {
                return Alert(title: Text("Failed to confirm account"), message: Text(error.localizedDescription))
            } else {
                return Alert(title: Text("Failed to create account"), message: Text(error.localizedDescription))
            }
        }
        .onTapGesture {
            self.hideKeyboard()
        }
        .preferredColorScheme(.light)
    }
    
    var createAccountView: some View {
        VStack(alignment: .leading, spacing: 15) {
            TextField("Email", text: self.$email)
                .authStyle()
                .keyboardType(.emailAddress)
            
            SecureField("Password", text: self.$password)
                .authStyle()
            
            HStack(alignment: .center) {
                Spacer()
                VStack(alignment: .leading, spacing: 15) {
                    HStack {
                        Image(systemName: "checkmark.seal.fill")
                        Text("Contains uppercase letter")
                    }
                    .foregroundColor(self.passwordContainsUppercase ? .white : ColorConstants.secondary)
                    
                    HStack {
                        Image(systemName: "checkmark.seal.fill")
                        Text("Contains lowercase letter")
                    }
                    .foregroundColor(self.passwordContainsLowercase ? .white : ColorConstants.secondary)
                    
                    HStack {
                        Image(systemName: "checkmark.seal.fill")
                        Text("Contains special character")
                    }
                    .foregroundColor(self.passwordContainsSpecialChar ? .white : ColorConstants.secondary)
                    
                    HStack {
                        Image(systemName: "checkmark.seal.fill")
                        Text("Contains number")
                    }
                    .foregroundColor(self.passwordContainsNumber ? .white : ColorConstants.secondary)
                    
                    HStack {
                        Image(systemName: "checkmark.seal.fill")
                        Text("Contains at least 8 characters")
                    }
                    .foregroundColor(self.passwordMinimumLength ? .white : ColorConstants.secondary)
                }
                .padding()
                .fontWeight(.regular)
                .font(.system(size: 14))
                
                Spacer()
            }
            
            Spacer()
            
            Button(action: self.createAccount) {
                if self.authStore.signingUp {
                    ProgressView()
                        .tint(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                } else {
                    Text("Create Account")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                }
            }
            .disabled(self.createAccountDisabled)
            .background(ColorConstants.tertiary)
            .opacity(self.createAccountDisabled ? 0.5 : 1.0)
            .frame(maxWidth: .infinity)
            .cornerRadius(10.0)
        }
        .padding(27.5)
    }
    
    var confirmationCodeView: some View {
        VStack(alignment: .center, spacing: 15) {
            TextField("Email", text: self.$email)
                .authStyle()
                .keyboardType(.emailAddress)
            
            TextField("Code", text: self.$confirmationCode)
                .authStyle()
                .padding([.bottom])
            
            Spacer()
            
            Button(action: self.confirmAccount) {
                if self.authStore.loggingIn || self.authStore.confirming {
                    ProgressView()
                        .tint(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                } else {
                    Text("Confirm Account")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                }
            }
            .disabled(self.confirmAccountDisabled)
            .background(ColorConstants.tertiary)
            .opacity(self.confirmAccountDisabled ? 0.5 : 1.0)
            .frame(maxWidth: .infinity)
            .cornerRadius(10.0)
        }
        .padding(27.5)
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
                KeychainStore.saveCredentials(Credentials(username: email, password: password))
                self.callback(authorization)
                
                // set this to false after successful signin so that we don't go back to create account page
                self.showConfirmationCode = false
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
