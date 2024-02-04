//
//  PermissionGroupBadge.swift
//  Nevvi
//
//  Created by Tyler Standal on 1/15/24.
//

import SwiftUI

struct PermissionGroupBadge: View {
    @State var groupName: String
    
    var body: some View {
        let textColor = ColorConstants.badgeText
        let backgroundColor = ColorConstants.badgeBackground

        return Text(groupName.uppercased())
            .font(.system(size: 12))
            .padding([.leading, .trailing], 12)
            .padding([.top, .bottom], 6)
            .foregroundColor(textColor)
            .background(backgroundColor)
            .cornerRadius(30)
            .fontWeight(.light)
    }
}

struct PermissionGroupBadge_Previews: PreviewProvider {
    static var previews: some View {
        PermissionGroupBadge(groupName: "Family")
    }
}
