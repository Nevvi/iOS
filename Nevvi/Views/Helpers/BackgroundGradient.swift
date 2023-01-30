//
//  BackgroundGradient.swift
//  Nevvi
//
//  Created by Tyler Cobb on 1/16/23.
//

import SwiftUI

struct BackgroundGradient: View {
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                ColorConstants.primary,
                ColorConstants.secondary
            ]),
            startPoint: .top,
            endPoint: .bottom)
        .edgesIgnoringSafeArea(.all)
    }
}

struct BackgroundGradient_Previews: PreviewProvider {
    static var previews: some View {
        BackgroundGradient()
    }
}
