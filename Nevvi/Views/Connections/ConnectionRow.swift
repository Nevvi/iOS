//
//  ConnectionRow.swift
//  Nevvi
//
//  Created by Tyler Cobb on 12/29/22.
//

import SwiftUI

struct ConnectionRow: View {
    var connection: Connection
    
    var body: some View {
        HStack {
            ZStack {
                AsyncImage(url: URL(string: connection.profileImage), content: { image in
                    image.resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                }, placeholder: {
                    ProgressView()
                        .padding(15)
                }).padding([.trailing], 10)
            }
            
            Text("\(connection.firstName) \(connection.lastName)")
        }
        .padding(5)
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
