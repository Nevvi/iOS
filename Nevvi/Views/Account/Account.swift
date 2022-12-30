//
//  AccountView.swift
//  Nevvi
//
//  Created by Tyler Cobb on 12/29/22.
//

import SwiftUI

struct Account: View {
    @ObservedObject var accountStore: AccountStore
    @State var user: User
    
    @State private var showPicker: Bool = false
    @State private var newProfileImage = UIImage()
    
    @State private var showError: Bool = false
    @State private var error: Error? = nil

    var body: some View {
        VStack {
            VStack {
                ZStack(alignment: .bottomTrailing) {
                    AsyncImage(url: URL(string: self.user.profileImage), content: { image in
                        image.resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(maxWidth: 100, maxHeight: 100)
                            .clipShape(Circle())
                    }, placeholder: {
                        ProgressView()
                    })
                    
                    Image(systemName: "plus")
                        .foregroundColor(.white)
                        .frame(width: 25, height: 25)
                        .background(Color.blue)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white, lineWidth: 2))
                }.onTapGesture {
                    self.showPicker = true
                }
                
                Text(self.user.email)
                    .foregroundColor(.secondary)
                    .font(.system(size: 14))
            }.padding(30)
            
            VStack(alignment: .leading) {
                Text("First Name")
                    .foregroundColor(.secondary)
                    .fontWeight(.light)
                    .font(.system(size: 14))
                
                TextField("Jane", text: self.$user.firstName ?? "")
                    .padding()
                    .overlay(RoundedRectangle(cornerRadius: 10.0).strokeBorder(Color.secondary, style: StrokeStyle(lineWidth: 1.0)))
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
            }
            .padding([.leading, .trailing])
            .padding([.bottom], 8)
            
            VStack(alignment: .leading) {
                Text("Last Name")
                    .foregroundColor(.secondary)
                    .fontWeight(.light)
                    .font(.system(size: 14))
                
                TextField("Doe", text: self.$user.lastName ?? "")
                    .padding()
                    .overlay(RoundedRectangle(cornerRadius: 10.0).strokeBorder(Color.secondary, style: StrokeStyle(lineWidth: 1.0)))
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
            }
            .padding([.leading, .trailing])
            .padding([.bottom], 8)
            
            VStack(alignment: .leading) {
                HStack {
                    Text("Phone Number")
                        .foregroundColor(.secondary)
                        .fontWeight(.light)
                        .font(.system(size: 14))
                    
                    Spacer()
                    
                    if self.user.phoneNumberConfirmed != nil && !self.user.phoneNumberConfirmed! {
                        Button {
                            // TODO - confirm phone
                        } label: {
                            Text("Verify")
                        }
                        .fontWeight(.light)
                        .font(.system(size: 14))
                    }
                }
                
                TextField("555-555-5555", text: self.$user.phoneNumber ?? "")
                    .padding()
                    .overlay(RoundedRectangle(cornerRadius: 10.0).strokeBorder(Color.secondary, style: StrokeStyle(lineWidth: 1.0)))
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
            }
            .padding([.leading, .trailing])
            .padding([.bottom], 8)
            
            VStack(alignment: .leading) {
                Text("Street Address")
                    .foregroundColor(.secondary)
                    .fontWeight(.light)
                    .font(.system(size: 14))
                
                TextField("111 Hollywood Ave", text: self.$user.address.street ?? "")
                    .padding()
                    .overlay(RoundedRectangle(cornerRadius: 10.0).strokeBorder(Color.secondary, style: StrokeStyle(lineWidth: 1.0)))
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
            }
            .padding([.leading, .trailing])
            .padding([.bottom], 8)
            
            VStack(alignment: .leading) {
                DatePicker("Birthday",
                           selection: self.$user.birthday ?? Date(),
                           displayedComponents: [.date]
                )
                .foregroundColor(.secondary)
                .fontWeight(.light)
                .font(.system(size: 14))
            }
            .padding()
            
            
        }
        .padding(27.5)
        .sheet(isPresented: self.$showPicker) {
            ImagePicker(callback: { (image: UIImage) in
                self.accountStore.uploadImage(image: image) { (result: Result<User, Error>) in
                    switch result {
                    case .failure(let error):
                        self.error = error
                        self.showError = true
                    case .success(_):
                        print("Success!")
                    }
                }
            }, sourceType: .photoLibrary)
        }
        .alert(isPresented: self.$showError) {
            Alert(title: Text("Failed to update user"), message: Text(self.error!.localizedDescription))
        }
        
    }

}

struct AccountView_Previews: PreviewProvider {
    static let modelData = ModelData()

    static var previews: some View {
        Account(accountStore: AccountStore(), user: modelData.user)
           .environmentObject(modelData)
    }
}
