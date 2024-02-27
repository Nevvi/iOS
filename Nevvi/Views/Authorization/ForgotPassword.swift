//
//  CreateAccount.swift
//  Nevvi
//
//  Created by Tyler Cobb on 12/30/22.
//

import SwiftUI

struct ForgotPassword: View {
    @State private var username: String
    @State private var confirmationCode = ""
    @State private var password = ""
    @State private var error: AuthorizationStore.AuthorizationError?
    
    @State private var showConfirmationCode: Bool
    @State private var hidePassword: Bool = true
    
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
        self.username.isEmpty || self.authStore.sendingResetCode
    }
    
    var resetPasswordDisabled: Bool {
        self.username.isEmpty ||
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
        self.init(authStore: authStore, callback: callback, username: "", showConfirmationCode: false)
    }
    
    init(authStore: AuthorizationStore, callback: @escaping (String, String) -> Void, showConfirmationCode: Bool) {
        self.init(authStore: authStore, callback: callback, username: "", showConfirmationCode: showConfirmationCode)
    }
    
    init(authStore: AuthorizationStore, callback: @escaping (String, String) -> Void, username: String, showConfirmationCode: Bool) {
        self.authStore = authStore
        self.callback = callback
        _username = State(initialValue: username)
        _showConfirmationCode = State(initialValue: showConfirmationCode)
    }
      
    var body: some View {
        VStack() {
            ZStack {
                Image("BackgroundBlur")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                
                VStack(alignment: .center, spacing: 20) {
                    Image("AppLogo")
                        .frame(width: 68, height: 68)
                        .padding([.top], 32)
                        .padding([.bottom], 32)
                    
                    if self.showConfirmationCode {
                        resetPasswordView
                    } else {
                        sendResetCodeView
                    }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 48)
                .frame(width: Constants.Width, alignment: .top)
            }
            .autocapitalization(.none)
            .edgesIgnoringSafeArea(.top)
            .onTapGesture {
                self.hideKeyboard()
            }
            .disabled(self.authStore.signingUp)
            .alert(item: self.$error) { error in
                if self.showConfirmationCode {
                    return Alert(title: Text("Failed to reset password"), message: Text(error.localizedDescription))
                } else {
                    return Alert(title: Text("Failed to send code"), message: Text(error.localizedDescription))
                }
            }
        }
    }
    
    var sendResetCodeView: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Text("Reset your password")
                .defaultStyle(size: 26, opacity: 0.7)
                .padding([.top], 16)
            
            Text("Where can we send a recovery code?")
                .defaultStyle(size: 18, opacity: 0.5)
                .multilineTextAlignment(.center)
                .padding([.vertical], 16)
            
            HStack(alignment: .center, spacing: 6) {
                Image(systemName: "phone")
                    .frame(width: 24, height: 24)
                    .foregroundColor(Color(red: 0, green: 0.07, blue: 0.17).opacity(0.4))
                
                TextField("Phone Number", text: self.$username)
                    .keyboardType(.phonePad)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(.white)
            .cornerRadius(40)
            .overlay(
              RoundedRectangle(cornerRadius: 40)
                .inset(by: 0.5)
                .stroke(Color(red: 0, green: 0.07, blue: 0.17).opacity(0.2), lineWidth: 1)
            )
                        
            Button(action: self.sendResetCode, label: {
                HStack {
                    Text("Send reset code".uppercased())
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14))
                }
                .fontWeight(.bold)
                .frame(maxWidth: .infinity)
                .font(.headline)
                .foregroundColor(.white)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .foregroundColor(ColorConstants.primary)
                        .opacity(self.authStore.sendingResetCode || self.username.isEmpty ? 0.5 : 1.0)
                )
            })
            .disabled(self.authStore.sendingResetCode || self.username.isEmpty)
            .padding([.bottom], 16)
            
            Spacer()
            Spacer()
            
            HStack {
                Text("Enter Code")
                    .foregroundColor(ColorConstants.primary)
                    .defaultStyle(size: 16, opacity: 0.5)
                    .onTapGesture {
                        self.showConfirmationCode = true
                    }
            }
        }
        .padding(.horizontal, 24)
        .frame(width: Constants.Width, alignment: .top)
        .disabled(self.authStore.sendingResetCode)
        .alert(item: self.$error) { error in
            return Alert(title: Text("Invalid login"), message: Text(error.localizedDescription))
        }
        .onTapGesture {
            self.hideKeyboard()
        }
    }
    
    var resetPasswordView: some View {
        VStack(spacing: 12) {
            Text("Reset your password")
                .defaultStyle(size: 26, opacity: 0.7)
                .multilineTextAlignment(.center)
                .padding([.top], 16)
            
            Spacer()
            
            HStack(alignment: .center, spacing: 6) {
                Image(systemName: "phone")
                    .frame(width: 24, height: 24)
                    .foregroundColor(Color(red: 0, green: 0.07, blue: 0.17).opacity(0.4))
                
                TextField("Phone Number", text: self.$username)
                    .keyboardType(.phonePad)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(.white)
            .cornerRadius(40)
            .overlay(
              RoundedRectangle(cornerRadius: 40)
                .inset(by: 0.5)
                .stroke(Color(red: 0, green: 0.07, blue: 0.17).opacity(0.2), lineWidth: 1)
            )
            
            HStack(alignment: .center, spacing: 6) {
                Image(systemName: "number")
                    .frame(width: 24, height: 24)
                    .foregroundColor(Color(red: 0, green: 0.07, blue: 0.17).opacity(0.4))
                
                TextField("Code", text: self.$confirmationCode)
                    .keyboardType(.numberPad)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(.white)
            .cornerRadius(40)
            .overlay(
              RoundedRectangle(cornerRadius: 40)
                .inset(by: 0.5)
                .stroke(Color(red: 0, green: 0.07, blue: 0.17).opacity(0.2), lineWidth: 1)
            )
            
            HStack(alignment: .center, spacing: 6) {
                Image(systemName: "lock")
                    .frame(width: 24, height: 24)
                    .foregroundColor(Color(red: 0, green: 0.07, blue: 0.17).opacity(0.4))
                
                if self.hidePassword {
                    SecureField("New Password", text: self.$password)
                    
                    Spacer()
                    
                    Image(systemName: "eye.slash")
                        .frame(width: 24, height: 24)
                        .foregroundColor(Color(red: 0, green: 0.07, blue: 0.17).opacity(0.4))
                        .onTapGesture {
                            self.hidePassword.toggle()
                        }
                } else  {
                    TextField("New Password", text: self.$password)
                    
                    Spacer()
                    
                    Image(systemName: "eye")
                        .frame(width: 24, height: 24)
                        .foregroundColor(Color(red: 0, green: 0.07, blue: 0.17).opacity(0.4))
                        .onTapGesture {
                            self.hidePassword.toggle()
                        }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(.white)
            .cornerRadius(40)
            .overlay(
              RoundedRectangle(cornerRadius: 40)
                .inset(by: 0.5)
                .stroke(Color(red: 0, green: 0.07, blue: 0.17).opacity(0.2), lineWidth: 1)
            )
            
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "checkmark.seal.fill")
                        Text("Contains uppercase letter")
                    }
                    .foregroundColor(self.passwordContainsUppercase ? ColorConstants.primary : ColorConstants.secondary)
                    
                    HStack {
                        Image(systemName: "checkmark.seal.fill")
                        Text("Contains lowercase letter")
                    }
                    .foregroundColor(self.passwordContainsLowercase ? ColorConstants.primary : ColorConstants.secondary)
                    
                    HStack {
                        Image(systemName: "checkmark.seal.fill")
                        Text("Contains special character")
                    }
                    .foregroundColor(self.passwordContainsSpecialChar ? ColorConstants.primary : ColorConstants.secondary)
                    
                    HStack {
                        Image(systemName: "checkmark.seal.fill")
                        Text("Contains number")
                    }
                    .foregroundColor(self.passwordContainsNumber ? ColorConstants.primary : ColorConstants.secondary)
                    
                    HStack {
                        Image(systemName: "checkmark.seal.fill")
                        Text("Contains at least 8 characters")
                    }
                    .foregroundColor(self.passwordMinimumLength ? ColorConstants.primary : ColorConstants.secondary)
                }
                .fontWeight(.regular)
                .font(.system(size: 14))
                
                Spacer()
            }
            .padding([.leading], 18)
            .padding([.bottom], 32)
                        
            Button(action: self.resetPassword, label: {
                HStack {
                    Text("Reset Password".uppercased())
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14))
                }
                .fontWeight(.bold)
                .frame(maxWidth: .infinity)
                .font(.headline)
                .foregroundColor(.white)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .foregroundColor(ColorConstants.primary)
                        .opacity(self.authStore.loggingIn ? 0.5 : 1.0)
                )
                .opacity(self.resetPasswordDisabled ? 0.5 : 1.0)
            })
            .disabled(self.resetPasswordDisabled)
            .padding([.bottom], 16)
            
            Spacer()
            Spacer()
            
            HStack {
                Text("Send Code")
                    .foregroundColor(ColorConstants.primary)
                    .defaultStyle(size: 16, opacity: 0.5)
                    .onTapGesture {
                        self.showConfirmationCode = false
                    }
            }
        }
        .disabled(self.authStore.signingUp)
    }
    
    func sendResetCode() {
        self.authStore.forgotPassword(username: username) { (result: Result<AuthorizationStore.ConfirmResponse, AuthorizationStore.AuthorizationError>) in
            switch result {
            case .success(_):
                self.showConfirmationCode = true
            case .failure(let error):
                self.username = ""
                self.error = error
            }
        }
    }
    
    func resetPassword() {
        self.authStore.confirmForgotPassword(username: username, code: confirmationCode, password: password) { (result: Result<AuthorizationStore.ConfirmResponse, AuthorizationStore.AuthorizationError>) in
            switch result {
            case .success(_):
                self.callback(self.username, self.password)
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
        ForgotPassword(authStore: AuthorizationStore(), callback: { username, password in }, username: "6129631237", showConfirmationCode: true)
    }
}
