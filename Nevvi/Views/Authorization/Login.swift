//
//  Login.swift
//  Nevvi
//
//  Created by Tyler Cobb on 12/29/22.
//

import AlertToast
import SwiftUI

struct Login: View {
    @State private var email = ""
    @State private var password = ""
    @State private var error: AuthorizationStore.AuthorizationError?
    
    @State private var toastText: String = ""
    @State private var showToast: Bool = false
    
    @State private var hidePassword: Bool = true
    
    @ObservedObject var authStore: AuthorizationStore
    
    var loginDisabled: Bool {
        self.email.isEmpty || self.password.isEmpty || self.authStore.loggingIn
    }
    
    private var callback: (Authorization) -> Void
    
    init(authStore: AuthorizationStore, callback: @escaping (Authorization) -> Void) {
        self.authStore = authStore
        self.callback = callback
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
                        .padding([.vertical], 32)
                                        
                    Text("Log in to your account")
                        .defaultStyle(size: 26, opacity: 0.7)
                        .padding([.vertical], 16)
                    
                    HStack(alignment: .center, spacing: 6) {
                        Image(systemName: "envelope")
                            .frame(width: 24, height: 24)
                            .foregroundColor(Color(red: 0, green: 0.07, blue: 0.17).opacity(0.4))
                        
                        TextField("Email", text: self.$email)
                            .keyboardType(.emailAddress)
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
                            ForgotPassword(authStore: self.authStore, callback: { email, password in
                                self.email = email
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
                    
                    Spacer()
                    
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
                        .disabled(self.loginDisabled)
                        .background(
                            RoundedRectangle(cornerRadius: 24)
                                .foregroundColor(ColorConstants.primary)
                                .opacity(self.loginDisabled ? 0.5 : 1.0)
                        )
                    })
                    .padding([.bottom], 16)
                    
                    HStack {
                        Text("No account?")
                            .defaultStyle(size: 14, opacity: 0.5)
                        
                        NavigationLink {
                            CreateAccount(authStore: self.authStore, callback: self.callback)
                        } label: {
                            Text("Create an account")
                                .foregroundColor(Color.blue)
                                .defaultStyle(size: 14, opacity: 0.5)
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 48)
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
            .onTapGesture {
                self.hideKeyboard()
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
                self.email = credentials.username
                self.password = credentials.password
                self.signIn()
            case .failure(let error):
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
            case .failure(let error):
                self.email = ""
                self.password = ""
                self.error = error
            }
        }
    }
}

struct Login_Previews: PreviewProvider {
    static var previews: some View {
        Login(authStore: AuthorizationStore()) { authorization in
            print(authorization)
        }
    }
}
