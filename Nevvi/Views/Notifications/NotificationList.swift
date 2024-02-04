//
//  ConnectionRequestList.swift
//  Nevvi
//
//  Created by Tyler Cobb on 12/31/22.
//

import SwiftUI

struct NotificationList: View {        
    var body: some View {
        NavigationView {
            VStack {
                Image("NotificationBell")
                
                Text("No Notifications")
                    .defaultStyle(size: 24, opacity: 0.7)
            }
            .navigationTitle("Notifications")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct NotificationList_Previews: PreviewProvider {
    static var previews: some View {
        NotificationList()
    }
}
