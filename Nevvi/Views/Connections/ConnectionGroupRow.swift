//
//  ConnectionRow.swift
//  Nevvi
//
//  Created by Tyler Cobb on 12/29/22.
//

import SwiftUI

struct ConnectionGroupRow: View {
    var connectionGroup: ConnectionGroup
    
    var body: some View {
        HStack {
            Text("\(connectionGroup.name) (\(connectionGroup.connections.count))")
        }
        .padding(10)
    }
}

struct ConnectionGroup_Previews: PreviewProvider {
    static var modelData = ModelData()
    
    static var previews: some View {
        Group {
            ConnectionGroupRow(connectionGroup: modelData.groups[0])
        }
        .previewLayout(.fixed(width: 300, height: 70))
    }
}
