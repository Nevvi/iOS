//
//  AccountView.swift
//  Nevvi
//
//  Created by Tyler Cobb on 12/29/22.
//

import SwiftUI

struct Account: View {
    @State var user: User

    var body: some View {
        Text(self.user.firstName)
    }

}

struct AccountView_Previews: PreviewProvider {
    static let modelData = ModelData()

    static var previews: some View {
        Account(user: modelData.user)
           .environmentObject(modelData)
    }
}
