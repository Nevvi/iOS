//
//  StackExtensions.swift
//  Nevvi
//
//  Created by Tyler Standal on 1/20/24.
//

import Foundation
import SwiftUI

extension VStack {
    func informationSection() -> some View {
        self
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 8)
            .frame(maxWidth: .infinity, alignment: .topLeading)
            .background(.white)
            .cornerRadius(16)
    }
    
    func informationSection(data: String) -> some View {
        self
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 8)
            .frame(maxWidth: .infinity, alignment: .topLeading)
            .background(.white)
            .cornerRadius(16)
            .contextMenu {
                Button(action: {
                    UIPasteboard.general.string = data
                }) {
                    Text("Copy to clipboard")
                    Image(systemName: "doc.on.doc")
                }
             }
    }
}

extension HStack {
    func informationSection() -> some View {
        self
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 8)
            .frame(maxWidth: .infinity, alignment: .topLeading)
            .background(.white)
            .cornerRadius(16)
    }
    
    func informationSection(data: String) -> some View {
        self
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 8)
            .frame(maxWidth: .infinity, alignment: .topLeading)
            .background(.white)
            .cornerRadius(16)
            .contextMenu {
                Button(action: {
                    UIPasteboard.general.string = data
                }) {
                    Text("Copy to clipboard")
                    Image(systemName: "doc.on.doc")
                }
             }
    }
}
