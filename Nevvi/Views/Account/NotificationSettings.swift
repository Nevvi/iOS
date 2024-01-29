//
//  NotificationSettings.swift
//  Nevvi
//
//  Created by Tyler Standal on 1/29/24.
//

import SwiftUI

struct NotificationSettings: View {
    
    @State private var enabled: Bool = false
    
    var body: some View {
        VStack(alignment: .center, spacing: 16) {
            Image("NotificationBell")
                .padding(.bottom)
            
            HStack {
                Text("Notification status: ")
                    .defaultStyle(size: 22, opacity: 1.0)
                
                Text("\(self.enabled ? "Enabled" : "Disabled")")
                    .font(.system(size: 22, weight: .bold))
            }
            
            Text("We use notifications to let you know when your connections have changed their information.")
                .defaultStyle(size: 16, opacity: 0.7)
            
            Text("You can enable or disable notifications inside your device settings.")
                .defaultStyle(size: 16, opacity: 0.7)
        }
        .padding(.bottom, 16)
        .multilineTextAlignment(.center)
        .padding(.horizontal, 18)
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            self.checkStatus()
        }
    }
    
    func checkStatus() -> Void {
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { settings in
            print(settings.authorizationStatus)
            self.enabled = settings.authorizationStatus == .authorized
        }
    }
}

struct NotificationSettings_Previews: PreviewProvider {
    static var previews: some View {
        NotificationSettings()
    }
}
