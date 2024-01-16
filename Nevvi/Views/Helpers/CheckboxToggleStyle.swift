//
//  CheckboxToggleStyle.swift
//  Nevvi
//
//  Created by Tyler Standal on 1/15/24.
//

import Foundation
import SwiftUI

struct CheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
 
            RoundedRectangle(cornerRadius: 5.0)
                .stroke(lineWidth: 2)
                .frame(width: 25, height: 25)
                .cornerRadius(5.0)
                .overlay {
                    Image(systemName: configuration.isOn ? "checkmark.square.fill" : "")
                        .resizable()
                        .frame(width: 25, height: 25)
                        .foregroundColor(ColorConstants.primary)
                }
                .onTapGesture {
                    withAnimation(.spring()) {
                        configuration.isOn.toggle()
                    }
                }
 
            configuration.label

        }
    }
}
