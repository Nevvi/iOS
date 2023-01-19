//
//  Login.swift
//  Nevvi
//
//  Created by Tyler Cobb on 12/29/22.
//

import SwiftUI

struct Login: View {
    @State private var email = ""
    @State private var password = ""
    @State private var error: AuthorizationStore.AuthorizationError?    
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
            VStack() {
                Spacer()
                
                Text("Welcome to Nevvi!")
                    .font(.largeTitle).foregroundColor(Color.white)
                    .padding([.top], 50)
                
                Text("Keep your contacts up to date!")
                    .font(.subheadline).foregroundColor(Color.white)
                    .padding([.top], 1)
                    .padding([.bottom], 50)
                
                VStack(alignment: .leading, spacing: 15) {
                    TextField("Email", text: self.$email)
                        .authStyle()
                        .keyboardType(.emailAddress)
                    
                    SecureField("Password", text: self.$password)
                        .authStyle()
                    
                    Button(action: self.signIn) {
                        Text("Sign In")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                    }
                    .disabled(self.loginDisabled)
                    .background(Color.green)
                    .opacity(self.loginDisabled ? 0.5 : 1.0)
                    .frame(maxWidth: .infinity)
                    .cornerRadius(10.0)
                }.padding(27.5)
                
                if self.authStore.loggingIn {
                    ProgressView().padding(45)
                } else if self.authStore.biometricType() != .none {
                    biometricLoginButton
                }
                
                Spacer()
                
                HStack {
                    NavigationLink("Create account") {
                        CreateAccount(authStore: self.authStore, callback: self.callback)
                    }
                    .padding()
                }
                .foregroundColor(.white)
                
            }
            .autocapitalization(.none)
            .disabled(self.authStore.loggingIn)
            .alert(item: self.$error) { error in
                return Alert(title: Text("Invalid login"), message: Text(error.localizedDescription))
            }
            .background(BackgroundGradient())
        }
        .accentColor(.white)
    }
    
    var biometricLoginButton: some View {
        Button(action: requestBiometricUnlock) {
            Image(systemName: self.authStore.biometricType() == .face ? "faceid" : "touchid")
                .resizable()
                .frame(width: 50, height: 50)
                .foregroundColor(.white)
        }
        .padding(30)
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
