//
//  ProfileImageSelector.swift
//  Nevvi
//
//  Created by Tyler Cobb on 1/16/23.
//

import SwiftUI

struct ProfileImageSelector: View {
    @EnvironmentObject var accountStore: AccountStore
    
    var height: CGFloat
    var width: CGFloat
    
    @State private var showPicker: Bool = false
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            AsyncImage(url: URL(string: self.accountStore.profileImage), content: { image in
                image.resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: width, height: height)
                    .clipShape(Circle())
            }, placeholder: {
                Image(systemName: "photo.circle")
                    .resizable()
                    .scaledToFit()
                    .frame(width: width, height: height)
                    .foregroundColor(.gray)
                    .clipShape(Circle())
            })
            
            Image(systemName: "plus")
                .foregroundColor(.white)
                .frame(width: 25, height: 25)
                .background(Color.blue)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.white, lineWidth: 2))
        }
        .onTapGesture {
            self.showPicker = true
        }
        .sheet(isPresented: self.$showPicker) {
            ImagePicker(callback: { (image: UIImage) in
                self.accountStore.uploadImage(image: image) { (result: Result<User, Error>) in
                    switch result {
                    case .failure(let error):
                        print("Something bad happened", error)
                    case .success(let user):
                        self.accountStore.update(user: user)
                    }
                }
            }, sourceType: .photoLibrary)
        }
    }
}

struct ProfileImageSelector_Previews: PreviewProvider {
    static let modelData = ModelData()
    static let accountStore = AccountStore(user: modelData.user)
    
    static var previews: some View {
        ProfileImageSelector(height: 100, width: 100)
            .environmentObject(accountStore)
    }
}
