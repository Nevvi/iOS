//
//  ConnectionDetail.swift
//  Nevvi
//
//  Created by Tyler Cobb on 12/29/22.
//

import SwiftUI

struct ConnectionDetail: View {
    @EnvironmentObject var modelData: ModelData
    var connection: Connection

    var connectionIndex: Int {
       modelData.connections.firstIndex(where: { $0.id == connection.id })!
    }
    
    var body: some View {
        ScrollView {
            CircleImage(image: connection.image)
                .offset(y: -130)
                .padding(.bottom, -130)
            
            VStack(alignment: .leading) {
                HStack {
                    Text(connection.firstName).font(.title)
                    Text(connection.lastName).font(.title)
                }
            }.padding()
        }
        .navigationTitle(connection.firstName)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ConnectionDetail_Previews: PreviewProvider {
    static let modelData = ModelData()

    static var previews: some View {
       ConnectionDetail(connection: modelData.connections[0])
           .environmentObject(modelData)
    }
}
