//
//  NoDataFound.swift
//  Nevvi
//
//  Created by Tyler Cobb on 1/16/23.
//

import SwiftUI

struct NoDataFound: View {
    var imageName: String
    var height: CGFloat
    var width: CGFloat
    var text: String = "No data found"
    
    var body: some View {
        HStack {
            Spacer()
            VStack {
                Image(systemName: "person.2.slash")
                    .resizable()
                    .frame(width: width, height: height)
                Text(self.text)
            }
            Spacer()
        }
        .padding([.top], 50)
    }
}

struct NoDataFound_Previews: PreviewProvider {
    static var previews: some View {
        NoDataFound(imageName: "person.2.slash", height: 120, width: 120)
    }
}
