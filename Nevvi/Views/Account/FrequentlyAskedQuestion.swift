//
//  FrequentlyAskedQuestion.swift
//  Nevvi
//
//  Created by Tyler Standal on 1/29/24.
//

import SwiftUI

struct FrequentlyAskedQuestion: View {
    
    var question: String
    var response: String
    
    @State var expanded: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(question)
                
                Spacer()
                
                if self.expanded {
                    Image(systemName: "chevron.up")
                } else {
                    Image(systemName: "chevron.down")
                }
            }
            .onTapGesture {
                withAnimation {
                    self.expanded.toggle()
                }
            }
            .foregroundColor(ColorConstants.primary)
            
            if self.expanded {
                Text(response)
                    .defaultStyle(size: 18, opacity: 0.7)
                    .transition(.opacity)
            }
        }
    }
}

struct FrequentlyAskedQuestion_Previews: PreviewProvider {
    static var previews: some View {
        FrequentlyAskedQuestion(
            question: "Who can see my data?",
            response: "You are not only in charge of WHO can see your data, but WHAT each person can see as well. You can create new permission groups on the settings page to restrict what information some users see."
        )
    }
}
