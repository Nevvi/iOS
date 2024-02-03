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
            .toolbar {
                ToolbarItem(placement: .navigation) {
                    HStack(alignment: .center) {
                        Text("Notifications")
                            .navigationHeader()
                    }
                    .padding(.leading, 8)
                    .padding(.horizontal, 16)
                    .padding(.top)
                    .frame(width: Constants.Width, alignment: .center)
                }
            }
        }
    }
}

struct NotificationList_Previews: PreviewProvider {
    static var previews: some View {
        NotificationList()
    }
}
