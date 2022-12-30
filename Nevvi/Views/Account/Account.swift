//
//  AccountView.swift
//  Nevvi
//
//  Created by Tyler Cobb on 12/29/22.
//

import SwiftUI

struct Account: View {
    @State var user: User

    var body: some View {
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
                }
            }
        }

}

struct AccountView_Previews: PreviewProvider {
    static let modelData = ModelData()

    static var previews: some View {
        Account(user: modelData.user)
           .environmentObject(modelData)
    }
}
