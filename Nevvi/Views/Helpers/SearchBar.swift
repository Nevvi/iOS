//
//  SearchBar.swift
//  Nevvi
//
//  Created by Tyler Standal on 2/2/24.
//

import SwiftUI

struct SearchBar: View {
    @StateObject var filter: DebouncedText
    
    var body: some View {
        HStack(alignment: .center, spacing: 4) {
            TextField("Search", text: self.$filter.text)
                .disableAutocorrection(true)
                .padding(.horizontal, 16)
                .padding(.vertical, 15.5)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.white)
                .cornerRadius(40)
                .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 4)
                .overlay(
                  RoundedRectangle(cornerRadius: 40)
                    .inset(by: 0.5)
                    .stroke(Color(red: 0, green: 0.07, blue: 0.17).opacity(0.08), lineWidth: 1)
                )
            
            Image(systemName: "xmark")
                .toolbarButtonStyle()
                .onTapGesture {
                    self.filter.text = ""
                }
        }
        .padding(.horizontal, 12)
        .padding(.top, 4)
        .padding(.bottom, 12)
    }
}

struct SearchBar_Previews: PreviewProvider {
    static var filter = DebouncedText()
    
    static var previews: some View {
        SearchBar(filter: filter)
    }
}
