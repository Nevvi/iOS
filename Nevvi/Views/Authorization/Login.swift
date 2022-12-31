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
    @State private var storeCredentials: Bool = false
    
    @ObservedObject var authStore: AuthorizationStore
    
    var loginDisabled: Bool {
        self.email.isEmpty || self.password.isEmpty
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
                
                Text("NEVVI")
                    .font(.largeTitle).foregroundColor(Color.white)
                    .padding([.top, .bottom], 40)
                
                VStack(alignment: .leading, spacing: 15) {
                    TextField("Email", text: self.$email)
                        .padding()
                        .keyboardType(.emailAddress)
                        .background(.white)
                        .cornerRadius(20.0)
                    
                    SecureField("Password", text: self.$password)
                        .padding()
                        .background(.white)
                        .cornerRadius(20.0)
                }.padding(27.5)
                
                Button(action: self.signIn) {
                    Text("Sign In")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: 300, height: 50)
                        .background(Color.green)
                        .cornerRadius(15.0)
                }.disabled(self.loginDisabled)
                
                if self.authStore.loggingIn {
                    ProgressView().padding(45)
                } else if self.authStore.biometricType() != .none {
                    Button {
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
                    } label: {
                        Image(systemName: self.authStore.biometricType() == .face ? "faceid" : "touchid")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .foregroundColor(.white)
                    }.padding(30)
                }
                
                Spacer()
                
                HStack {
                    NavigationLink("Create account") {
                        CreateAccount(authStore: self.authStore, callback: self.callback)
                    }.padding()
                }
                .foregroundColor(.white)
                
            }
            .autocapitalization(.none)
            .disabled(self.authStore.loggingIn)
            .alert(item: self.$error) { error in
                if error == .credentialsNotSaved {
                    return Alert(title: Text("Credentials not saved"),
                                 message: Text(error.localizedDescription),
                                 primaryButton: .default(Text("OK"), action: {
                        self.storeCredentials = true
                    }),
                                 secondaryButton: .cancel())
                } else {
                    return Alert(title: Text("Invalid login"), message: Text(error.localizedDescription))
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
    
    func signIn() {
        self.authStore.login(email: email, password: password) { (result: Result<Authorization, AuthorizationStore.AuthorizationError>) in
            switch result {
            case .success(let authorization):
                // TODO - if login doesn't match existing creds in keychain overwrite?
                if self.storeCredentials && KeychainStore.saveCredentials(Credentials(username: email, password: password)) {
                    self.storeCredentials = false
                }
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
