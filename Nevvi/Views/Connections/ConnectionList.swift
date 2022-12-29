//
//  ConnectionList.swift
//  Nevvi
//
//  Created by Tyler Cobb on 12/29/22.
//

import SwiftUI

struct ConnectionList: View {
    @EnvironmentObject var modelData: ModelData
    
    var body: some View {
        Text("Hello, World")
//        NavigationView {
//            List {
//                ForEach(modelData.connections) { connection in
//                    NavigationLink {
//                        ConnectionDetail(connection: connection)
//                    } label: {
//                        ConnectionRow(connection: connection)
//                    }
//                }
//            }.navigationTitle("Nevvi")
//        }
    }
}

struct ConnectionList_Previews: PreviewProvider {
    static var previews: some View {
        ConnectionList().environmentObject(ModelData())
    }
}
