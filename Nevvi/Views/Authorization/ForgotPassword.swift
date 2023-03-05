//
//  CreateAccount.swift
//  Nevvi
//
//  Created by Tyler Cobb on 12/30/22.
//

import SwiftUI

struct ForgotPassword: View {
    @State private var email = ""
    @State private var confirmationCode = ""
    @State private var password = ""
    @State private var error: AuthorizationStore.AuthorizationError?
    
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
    
    var sendResetCodeDisabled: Bool {
        self.email.isEmpty || self.authStore.sendingResetCode
    }
    
    var resetPasswordDisabled: Bool {
        self.email.isEmpty ||
        self.confirmationCode.isEmpty ||
        self.password.isEmpty ||
        self.authStore.resettingPassword ||
        self.authStore.loggingIn ||
        !self.passwordContainsUppercase ||
        !self.passwordContainsLowercase ||
        !self.passwordContainsSpecialChar ||
        !self.passwordContainsNumber ||
        !self.passwordMinimumLength
    }
    
    private var callback: (String, String) -> Void
    
    @Environment(\.presentationMode) var presentationMode
    
    init(authStore: AuthorizationStore, callback: @escaping (String, String) -> Void) {
        self.authStore = authStore
        self.callback = callback
        _showConfirmationCode = State(initialValue: false)
    }
    
    init(authStore: AuthorizationStore, callback: @escaping (String, String) -> Void, showConfirmationCode: Bool) {
        self.authStore = authStore
        self.callback = callback
        _showConfirmationCode = State(initialValue: showConfirmationCode)
    }
      
    var body: some View {
        VStack() {
            Spacer()
            
            Text(self.showConfirmationCode ? "Almost done!" : "Forgot password?")
                .font(.largeTitle).foregroundColor(Color.white)
                .padding([.top], 30)
            
            Text(self.showConfirmationCode ? "Enter the code you received in your email along with your new password" : "No worries... we're here to help")
                .font(.subheadline)
                .foregroundColor(Color.white)
                .multilineTextAlignment(.center)
                .padding([.top], 1)
                .padding([.leading, .trailing], 30)
                .padding([.bottom], 50)
            
            if self.showConfirmationCode {
                resetPasswordView
            } else {
                sendResetCodeView
            }
            
            Spacer()
            Spacer()
        }
        .autocapitalization(.none)
        .disabled(self.authStore.signingUp)
        .background(BackgroundGradient())
        .alert(item: self.$error) { error in
            if self.showConfirmationCode {
                return Alert(title: Text("Failed to reset password"), message: Text(error.localizedDescription))
            } else {
                return Alert(title: Text("Failed to send code"), message: Text(error.localizedDescription))
            }
        }
    }
    
    var sendResetCodeView: some View {
        VStack(alignment: .leading, spacing: 15) {
            TextField("Email", text: self.$email)
                .authStyle()
                .keyboardType(.emailAddress)
            
            Spacer()
            
            Button(action: self.sendResetCode) {
                Text("Send Code")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
            }
            .disabled(self.sendResetCodeDisabled)
            .background(ColorConstants.tertiary)
            .opacity(self.sendResetCodeDisabled ? 0.5 : 1.0)
            .frame(maxWidth: .infinity)
            .cornerRadius(10.0)
        }
        .padding([.leading, .trailing], 27.5)
    }
    
    var resetPasswordView: some View {
        VStack(alignment: .leading, spacing: 15) {
            TextField("Email", text: self.$email)
                .authStyle()
                .disabled(true)
                .keyboardType(.emailAddress)
            
            TextField("Code", text: self.$confirmationCode)
                .authStyle()
            
            SecureField("New Password", text: self.$password)
                .authStyle()
            
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
            .padding([.leading, .bottom])
            .fontWeight(.regular)
            .font(.system(size: 14))
            
            Spacer()
            
            Button(action: self.resetPassword) {
                Text("Reset Password")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
            }
            .disabled(self.resetPasswordDisabled)
            .background(ColorConstants.tertiary)
            .opacity(self.resetPasswordDisabled ? 0.5 : 1.0)
            .frame(maxWidth: .infinity)
            .cornerRadius(10.0)
        }
        .padding([.leading, .trailing], 27.5)
    }
    
    func sendResetCode() {
        self.authStore.forgotPassword(email: email) { (result: Result<AuthorizationStore.ConfirmResponse, AuthorizationStore.AuthorizationError>) in
            switch result {
            case .success(_):
                self.showConfirmationCode = true
            case .failure(let error):
                self.email = ""
                self.error = error
            }
        }
    }
    
    func resetPassword() {
        self.authStore.confirmForgotPassword(email: email, code: confirmationCode, password: password) { (result: Result<AuthorizationStore.ConfirmResponse, AuthorizationStore.AuthorizationError>) in
            switch result {
            case .success(_):
                self.callback(self.email, self.password)
                self.presentationMode.wrappedValue.dismiss()
            case .failure(let error):
                self.confirmationCode = ""
                self.password = ""
                self.error = error
            }
        }
    }

}

struct ForgotPassword_Previews: PreviewProvider {
    static var previews: some View {
        ForgotPassword(authStore: AuthorizationStore(), callback: { email, password in }, showConfirmationCode: true)
    }
}
