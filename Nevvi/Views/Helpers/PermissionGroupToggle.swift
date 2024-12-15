//
//  PermissionGroupToggle.swift
//  Nevvi
//
//  Created by Tyler Standal on 1/15/24.
//

import SwiftUI

struct PermissionGroupToggle: View {
    @State var isOn = false
    @State var groupName: String
    
    var callback: (Bool) -> Void
        
    var body: some View {
        Toggle(isOn: $isOn) {
            Text(groupName)
        }
        .toggleStyle(CheckboxToggleStyle())
        .disabled(self.groupName == "All Info")
        .opacity(self.groupName == "All Info" ? 0.5 : 1.0)
        .onChange(of: self.isOn) { newValue in
            callback(newValue)
        }
        .onAppear {
            self.isOn = self.isOn || self.groupName == "All Info"
        }
    }
}

struct PermissionGroupToggle_Previews: PreviewProvider {
    static var previews: some View {
        PermissionGroupToggle(groupName: "Family") { isOn in
            
        }
    }
}
