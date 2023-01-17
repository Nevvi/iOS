//
//  ProfileImage.swift
//  Nevvi
//
//  Created by Tyler Cobb on 1/16/23.
//

import SwiftUI

struct ProfileImage: View {
    var imageUrl: String
    var height: CGFloat
    var width: CGFloat
    
    var body: some View {
        AsyncImage(url: URL(string: imageUrl), content: { image in
            image.resizable()
                .aspectRatio(contentMode: .fill)
                .frame(maxWidth: width, maxHeight: height)
                .clipShape(Circle())
        }, placeholder: {
            Image(systemName: "photo.circle")
                .resizable()
                .scaledToFit()
                .frame(width: width, height: height)
                .foregroundColor(.gray)
                .clipShape(Circle())
        })
    }
}

struct ProfileImage_Previews: PreviewProvider {
    static var previews: some View {
        ProfileImage(imageUrl: ModelData().user.profileImage, height: 80, width: 80)
    }
}
