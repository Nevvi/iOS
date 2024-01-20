//
//  ConnectionRow.swift
//  Nevvi
//
//  Created by Tyler Cobb on 12/29/22.
//

import SwiftUI
import NukeUI

struct ConnectionRow: View {
    var connection: Connection
    
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            ZStack(alignment: .bottom) {
                Rectangle()
                .foregroundColor(.clear)
                .frame(width: 63, height: 63)
                .background(
                    LazyImage(url: URL(string: connection.profileImage), resizingMode: .aspectFill)
                )
                .cornerRadius(63)
                .padding([.bottom], 8)
                                
                Text(self.connection.permissionGroup ?? "Unknown")
                    .asPermissionGroupBadge(bgColor: Color(red: 0.82, green: 0.88, blue: 1))
            }
            
            VStack {
                Text("\(connection.firstName) \(connection.lastName)")
                    .defaultStyle(size: 18, opacity: 1.0)
                
                // TODO - add phone/email if we have access
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .overlay(
            Rectangle()
                .inset(by: 0.5)
                .stroke(Color(red: 0, green: 0.07, blue: 0.17).opacity(0.04), lineWidth: 1)
        )
    }
}

struct ConnectionRow_Previews: PreviewProvider {
    static var connections = ModelData().connectionResponse.users
    
    static var previews: some View {
        Group {
            ConnectionRow(connection: connections[0])
            ConnectionRow(connection: connections[1])
        }
        .previewLayout(.fixed(width: 300, height: 70))
    }
}
