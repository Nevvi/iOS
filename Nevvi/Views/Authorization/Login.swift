//
//  Login.swift
//  Nevvi
//
//  Created by Tyler Cobb on 12/29/22.
//

import AlertToast
import SwiftUI

struct Login: View {
    @State private var username = ""
    @State private var password = ""
    @State private var error: AuthorizationStore.AuthorizationError?
    
    @State private var toastText: String = ""
    @State private var showToast: Bool = false
    @State private var passwordReset: Bool = false
    
    @State private var hidePassword: Bool = true
    
    @ObservedObject var authStore: AuthorizationStore
    
    var loginDisabled: Bool {
        self.username.isEmpty || self.password.isEmpty || self.authStore.loggingIn || self.authStore.sendingResetCode
    }
        
    init(authStore: AuthorizationStore) {
        self.authStore = authStore
    }
      
    var body: some View {
        NavigationView {
            if self.passwordReset {
                ForgotPassword(
                    authStore: self.authStore,
                    callback: { username, password in
                        self.passwordReset = false
                        self.username = username
                        self.password = password
                        self.signIn()
                    },
                    username: self.username,
                    showConfirmationCode: true
                )
            } else {
                ZStack {
                    Image("BackgroundBlur")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                    
                    VStack(alignment: .center, spacing: 20) {
                        Image("AppLogo")
                            .frame(width: 68, height: 68)
                            .padding([.top], 80)
                        
                        Spacer()
                        
                        Text("Log in to your account")
                            .defaultStyle(size: 26, opacity: 0.7)
                            .padding([.bottom], 16)
                        
                        HStack(alignment: .center, spacing: 6) {
                            Image(systemName: "phone")
                                .frame(width: 24, height: 24)
                                .foregroundColor(Color(red: 0, green: 0.07, blue: 0.17).opacity(0.4))
                            
                            TextField("Phone Number", text: self.$username)
                                .keyboardType(.phonePad)
                            
                            Spacer()
                            
                            Button(action: requestBiometricUnlock, label: {
                                Image(systemName: self.authStore.biometricType() == .face ? "faceid" : "touchid")
                                    .resizable()
                                    .frame(width: 24, height: 24)
                                    .foregroundColor(ColorConstants.primary)
                            })
                            .disabled(self.authStore.loggingIn)
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
                                
                                Spacer()
                                
                                Image(systemName: "eye.slash")
                                    .frame(width: 24, height: 24)
                                    .foregroundColor(Color(red: 0, green: 0.07, blue: 0.17).opacity(0.4))
                                    .onTapGesture {
                                        self.hidePassword.toggle()
                                    }
                            } else  {
                                TextField("Password", text: self.$password)
                                
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
                            NavigationLink {
                                ForgotPassword(authStore: self.authStore, callback: { username, password in
                                    self.username = username
                                    self.password = password
                                    self.toastText = "Password reset!"
                                    self.showToast = true
                                })
                            } label: {
                                Text("Forget Password?")
                                    .font(Font.custom("SF Pro Text", size: 14).weight(.medium)
                                    )
                                    .foregroundColor(Color(red: 0, green: 0.6, blue: 1))
                            }
                            
                            Spacer()
                        }
                        
                        Button(action: self.signIn, label: {
                            HStack {
                                Text("Log In".uppercased())
                                
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
                                    .opacity(self.loginDisabled ? 0.5 : 1.0)
                            )
                        })
                        .padding([.bottom], 16)
                        .disabled(self.loginDisabled)
                        
                        Spacer()
                        Spacer()
                        
                        HStack {
                            Text("No account?")
                                .defaultStyle(size: 16, opacity: 0.5)
                            
                            NavigationLink {
                                CreateAccount(authStore: self.authStore)
                            } label: {
                                Text("Create an account")
                                    .foregroundColor(ColorConstants.primary)
                                    .defaultStyle(size: 16, opacity: 0.5)
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 48)
                    .frame(width: Constants.Width, alignment: .top)
                }
                .edgesIgnoringSafeArea(.top)
                .autocapitalization(.none)
                .disabled(self.authStore.loggingIn)
                .alert(item: self.$error) { error in
                    return Alert(title: Text("Invalid login"), message: Text(error.localizedDescription))
                }
                .toast(isPresenting: $showToast){
                    AlertToast(displayMode: .banner(.slide), type: .complete(Color.green), title: self.toastText)
                }
                .toast(isPresenting: $authStore.showToast, duration: 5.0) {
                    AlertToast(displayMode: .hud, type: authStore.toastType, title: authStore.toastText)
                }
                .onTapGesture {
                    self.hideKeyboard()
                }
            }
        }
    }
    
    var biometricLoginButton: some View {
        Button(action: requestBiometricUnlock) {
            Image(systemName: self.authStore.biometricType() == .face ? "faceid" : "touchid")
                .resizable()
                .frame(width: 50, height: 50)
                .foregroundColor(.white)
        }
        .padding(30)
        .disabled(self.authStore.loggingIn)
    }
    
    func requestBiometricUnlock() {
        self.authStore.requestBiometricUnlock {(result: Result<Credentials, AuthorizationStore.AuthorizationError>) in
            switch result {
            case .success(let credentials):
                self.username = credentials.username
                self.password = credentials.password
                self.signIn()
            case .failure(let error):
                self.error = error
            }
        }
    }
    
    func signIn() {
        self.authStore.login(username: self.username, password: password) { (result: Result<Authorization, AuthorizationStore.AuthorizationError>) in
            switch result {
            case .success(_):
                KeychainStore.saveCredentials(Credentials(username: self.username, password: password))
            case .failure(let error):
                switch error {
                case .passwordResetRequired:
                    self.authStore.forgotPassword(username: username) { (result: Result<AuthorizationStore.ConfirmResponse, AuthorizationStore.AuthorizationError>) in
                        switch result {
                        case .success(_):
                            self.passwordReset = true
                        case .failure(let error):
                            self.error = error
                            self.username = ""
                            self.password = ""
                        }
                    }
                default:
                    self.error = error
                    self.username = ""
                    self.password = ""
                }
            }
        }
    }
}

struct Login_Previews: PreviewProvider {
    static var previews: some View {
        Login(authStore: AuthorizationStore())
    }
}
