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
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center) {
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(connectionGroup.name)")
                        .defaultStyle(size: 20, opacity: 1.0)
                    
                    HStack(spacing: 8) {
                        Text("\(connectionGroup.connections.count) \(connectionGroup.connections.count == 1 ? "member" : "members")")
                            .defaultStyle(size: 14, opacity: 0.4)
                        
                        if !connectionGroup.invites.isEmpty {
                            Text("•")
                                .defaultStyle(size: 14, opacity: 0.4)
                            
                            Text("\(connectionGroup.invites.count) pending")
                                .defaultStyle(size: 14, opacity: 0.4)
                                .foregroundColor(ColorConstants.primary)
                        }
                    }
                }
                .padding(0)
                .frame(maxWidth: .infinity, alignment: .topLeading)
            }
            .padding(.horizontal, 0)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity, alignment: .top)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .background(.white)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(ColorConstants.badgeBackground, lineWidth: 1)
        )
    }
}

struct ConnectionGroup_Previews: PreviewProvider {
    static let modelData = ModelData()
    
    static var previews: some View {
        Group {
            ConnectionGroupRow(connectionGroup: modelData.groups[0])
        }
        .previewLayout(.fixed(width: 300, height: 70))
    }
}
