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
    
    @ObservedObject var authStore: AuthorizationStore
    private var callback: (Authorization) -> Void
    
    init(authStore: AuthorizationStore, callback: @escaping (Authorization) -> Void) {
        self.authStore = authStore
        self.callback = callback
    }
      
    var body: some View {
      VStack() {
        Spacer()
        
        Text("NEVVI")
            .font(.largeTitle).foregroundColor(Color.white)
            .padding([.top, .bottom], 40)
                    
        VStack(alignment: .leading, spacing: 15) {
            TextField("Email", text: self.$email)
              .padding()
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
        }
          
        Spacer()
          
        Text("Dont have an account? Sign Up")
              .padding()
              .foregroundColor(.white)
          
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
    
    func signIn() {
        self.authStore.login(email: email, password: password) { (result: Result<Authorization, Error>) in
            switch result {
            case .success(let authorization):
                self.callback(authorization)
            case .failure(let error):
                print(error)
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
