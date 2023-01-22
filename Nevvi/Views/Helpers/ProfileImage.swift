//
//  ProfileImage.swift
//  Nevvi
//
//  Created by Tyler Cobb on 1/16/23.
//

import SwiftUI
import NukeUI

struct ProfileImage: View {
    var imageUrl: String
    var height: CGFloat
    var width: CGFloat
    
    var body: some View {
        LazyImage(url: URL(string: imageUrl), resizingMode: .aspectFill)
            .frame(width: width, height: height)
            .clipShape(Circle())
    }
}

struct ProfileImage_Previews: PreviewProvider {
    static var previews: some View {
        ProfileImage(imageUrl: ModelData().user.profileImage, height: 80, width: 80)
    }
}
