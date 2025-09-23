//
//  CreateAccount.swift
//  Nevvi
//
//  Created by Tyler Cobb on 12/30/22.
//

import SwiftUI
import AlertToast

struct CreateAccount: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @State private var username = ""
    @State private var confirmationCode = ""
    @State private var password = ""
    @State private var error: AuthorizationStore.AuthorizationError?
    @State private var storeCredentials: Bool = false
    
    @State private var toastText: String = ""
    @State private var showToast: Bool = false
    @State private var showConfirmationCode: Bool
    @State private var hidePassword: Bool = true
    
    @State private var showPrivacySheet: Bool = false
    
    
    @ObservedObject var authStore: AuthorizationStore
    
    var passwordContainsUppercase: Bool {
        !self.password.isEmpty && self.password.contains(where: { char in char.isUppercase
        })
    }
    
    var passwordContainsLowercase: Bool {
        !self.password.isEmpty && self.password.contains(where: { char in char.isLowercase
        })
    }
    
    var passwordContainsNumber: Bool {
        !self.password.isEmpty && self.password.contains(where: { char in  char.isNumber
        })
    }
    
    var passwordContainsSpecialChar: Bool {
        !self.password.isEmpty && self.password.range(of: ".*[^A-Za-z0-9].*", options: .regularExpression) != nil
    }
    
    var passwordMinimumLength: Bool {
        !self.password.isEmpty && self.password.count >= 8
    }
    
    var createAccountDisabled: Bool {
        self.username.isEmpty ||
        self.password.isEmpty ||
        self.authStore.signingUp ||
        !self.passwordContainsUppercase ||
        !self.passwordContainsLowercase ||
        !self.passwordContainsSpecialChar ||
        !self.passwordContainsNumber ||
        !self.passwordMinimumLength
    }
    
    var confirmAccountDisabled: Bool {
        self.username.isEmpty || self.confirmationCode.isEmpty || self.authStore.confirming || self.authStore.loggingIn
    }
    
    var resendCodeDisabled: Bool {
        self.username.isEmpty || self.authStore.confirming || self.authStore.loggingIn || self.authStore.sendingResetCode
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
            ZStack {
                Image("BackgroundBlur")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                
                VStack(alignment: .center, spacing: 20) {
                    Image("AppLogo")
                        .frame(width: 68, height: 68)
                        .padding([.top], 80)
                                      
                    if self.showConfirmationCode {
                        confirmationCodeView
                    } else {
                        createAccountView
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 48)
                .frame(width: Constants.Width, alignment: .top)
            }
            .edgesIgnoringSafeArea(.top)
            .autocapitalization(.none)
            .alert(item: self.$error) { error in
                return Alert(title: Text("Failed to create account"), message: Text(error.localizedDescription))
            }
            .toast(isPresenting: $showToast){
                AlertToast(displayMode: .banner(.slide), type: .complete(Color.green), title: self.toastText)
            }
            .onTapGesture {
                self.hideKeyboard()
            }
        }
        
    }
    
    var createAccountView: some View {
        VStack(spacing: 12) {
            Text("Create free Nevvi account")
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
                Image(systemName: "lock")
                    .frame(width: 24, height: 24)
                    .foregroundColor(Color(red: 0, green: 0.07, blue: 0.17).opacity(0.4))
                
                if self.hidePassword {
                    SecureField("Password", text: self.$password)
                        .submitLabel(.done)
                    
                    Spacer()
                    
                    Image(systemName: "eye.slash")
                        .frame(width: 24, height: 24)
                        .foregroundColor(Color(red: 0, green: 0.07, blue: 0.17).opacity(0.4))
                        .onTapGesture {
                            self.hidePassword.toggle()
                        }
                } else  {
                    TextField("Password", text: self.$password)
                        .submitLabel(.done)
                    
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
            
            Button(action: self.createAccount, label: {
                HStack {
                    Text("Create Account".uppercased())
                    
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
            })
            .opacity(self.createAccountDisabled ? 0.5 : 1.0)
            .disabled(self.createAccountDisabled)
            .padding([.bottom], 16)
            
            HStack {
                Text(privacyText)
                .font(.footnote)
                .foregroundColor(.secondary)
                .environment(\.openURL, OpenURLAction { _ in
                    showPrivacySheet = true
                    return .handled
                })

            }
            
            Spacer()
            Spacer()
                        
            HStack {
                Text("Need to confirm an account?")
                    .defaultStyle(size: 16, opacity: 0.5)
                
                Text("Enter code")
                    .foregroundColor(ColorConstants.primary)
                    .defaultStyle(size: 16, opacity: 0.5)
                    .onTapGesture {
                        self.showConfirmationCode = true
                    }
            }
        }
        .disabled(self.authStore.signingUp)
        .sheet(isPresented: self.$showPrivacySheet) {
            PrivacySettings()
                .presentationDetents([.large])
        }
    }
    
    private var privacyText: AttributedString {
        var text = AttributedString("By creating an account, you agree to our Privacy Policy")
        
        if let range = text.range(of: "Privacy Policy") {
            text[range].link = URL(string: "privacy://policy") // Dummy URL
            text[range].foregroundColor = .blue
        }
        
        return text
    }
    
    var confirmationCodeView: some View {
        VStack(spacing: 12) {
            Spacer()
            
            Text("Confirm your Nevvi account")
                .defaultStyle(size: 26, opacity: 0.7)
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
                        
            Button(action: self.confirmAccount, label: {
                HStack {
                    Text("Confirm Account".uppercased())
                    
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
                .opacity(self.confirmAccountDisabled ? 0.5 : 1.0)
                .disabled(self.confirmAccountDisabled)
            })
            .padding([.bottom], 16)
            
            Text("Resend Confirmation Code")
                .foregroundColor(ColorConstants.primary)
                .defaultStyle(size: 16, opacity: 0.5)
                .opacity(self.resendCodeDisabled ? 0.5 : 1.0)
                .disabled(self.resendCodeDisabled)
                .onTapGesture {
                    self.resendCode()
                }
            
            Spacer()
            Spacer()
                        
            HStack {
                Text("Need to create an account?")
                    .defaultStyle(size: 16, opacity: 0.5)

                Text("Create Account")
                    .foregroundColor(ColorConstants.primary)
                    .defaultStyle(size: 16, opacity: 0.5)
                    .onTapGesture {
                        self.showConfirmationCode = false
                    }
            }
        }.disabled(self.authStore.confirming)
    }
    
    func createAccount() {
        self.authStore.signUp(username: username, password: password) { (result: Result<AuthorizationStore.SignupResponse, AuthorizationStore.AuthorizationError>) in
            switch result {
            case .success(_):
                self.showConfirmationCode = true
            case .failure(let error):
                self.username = ""
                self.password = ""
                self.error = error
            }
        }
    }
    
    func confirmAccount() {
        self.authStore.confirmAccount(username: username, code: confirmationCode) { (result: Result<AuthorizationStore.ConfirmResponse, AuthorizationStore.AuthorizationError>) in
            switch result {
            case .success(_):
                if self.username.isEmpty == false && self.password.isEmpty == false {
                    self.signIn()
                    self.username = ""
                    self.confirmationCode = ""
                } else {
                    self.toastText = "Account confirmed!"
                    self.showToast = true
                    self.username = ""
                    self.confirmationCode = ""
                    self.presentationMode.wrappedValue.dismiss()
                }
            case .failure(let error):
                self.confirmationCode = ""
                self.error = error
            }
        }
    }
    
    func resendCode() {
        self.authStore.resendSignupCode(username: username) { (result: Result<AuthorizationStore.ConfirmResponse, AuthorizationStore.AuthorizationError>) in
            switch result {
            case .success(_):
                self.toastText = "Confirmation code sent"
                self.showToast = true
            case .failure(let error):
                self.username = ""
                self.error = error
            }
        }
    }
    
    func signIn() {
        self.authStore.login(username: username, password: password) { (result: Result<Authorization, AuthorizationStore.AuthorizationError>) in
            switch result {
            case .success(let authorization):
                KeychainStore.saveCredentials(Credentials(username: username, password: password))
                self.callback(authorization)
                
                // set this to false after successful signin so that we don't go back to create account page
                self.showConfirmationCode = false
            case .failure(let error):
                self.username = ""
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
