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
            connection.image
                .resizable()
                .frame(width: 50, height: 50)
            
            Text(connection.firstName)
            Text(connection.lastName)
        }.padding()
    }
}

struct ConnectionRow_Previews: PreviewProvider {
    static var connections = ModelData().connections
    
    static var previews: some View {
        Group {
            ConnectionRow(connection: connections[0])
            ConnectionRow(connection: connections[1])
        }
        .previewLayout(.fixed(width: 300, height: 70))
    }
}
