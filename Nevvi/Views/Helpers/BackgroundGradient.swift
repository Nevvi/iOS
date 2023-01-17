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
                Color(UIColor(hexString: "#33897F")),
                Color(UIColor(hexString: "#5293B8"))
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
