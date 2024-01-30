//
//  FrequentlyAskedQuestions.swift
//  Nevvi
//
//  Created by Tyler Standal on 1/29/24.
//

import SwiftUI

struct FrequentlyAskedQuestionList: View {
    
    struct QuestionResponse {
        var question: String
        var response: String
    }
    
    @State var questions: [QuestionResponse] = [
        QuestionResponse(
            question: "Who can see my information?",
            response: "You are not only in charge of WHO can see your data, but WHAT each person can see as well. You can create new permission groups on the settings page to restrict what information some users see."
        ),
        QuestionResponse(
            question: "Why does Nevvi need access to my contacts?",
            response: "By giving Nevvi access to your contacts, we can sync all updated connection information to your phone's contact book. Our goal is for you to use Nevvi as little as possible after you make connections. Once a connection is made you can continue to use your phone like normal, but with confidence that your contact's data is always up to date."
        ),
        QuestionResponse(
            question: "How do I find new connections?",
            response: "There are 2 easy ways to find connections. First, on the New Connections screen we automatically suggest connections we found in your contact book. Second, you can search for connections by name."
        ),
        QuestionResponse(
            question: "Can I modify or remove a connection?",
            response: "You always have complete control over who you are connected to and what they can see. Once a connection is made you can select them from your connection list for more detailed info. On the connection detail page you can edit the connection and change permission groups, or if you no longer wish to connect you can delete the connection."
        ),
        QuestionResponse(
            question: "Why can't I find a connection?",
            response: "There could be a couple reasons why you can't find someone to connect with on Nevvi. First, they may not have an account with us. Second, you may have already requested them. Lastly, check your Blocked User list to see if you accidentally blocked them."
        ),
        QuestionResponse(
            question: "What are connection groups for?",
            response: "Connection groups are a way to easily take action on a select group of people. For example, if you give out holiday cards every year you can create a connection group for those you send cards to. Instead of asking everyone for their address, go to that connection group and export all the most up to date data to your email."
        )
    ]
    
    var body: some View {
        VStack {
            Text("Frequently Asked Questions")
                .font(.system(size: 26, weight: .bold))
            
            Divider()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    ForEach(self.questions, id: \.question) { question in
                        FrequentlyAskedQuestion(
                            question: question.question,
                            response: question.response
                        )
                    }
                }
                .padding(.vertical, 16)
                .padding(.horizontal, 20)
            }
        }
        .padding(.vertical, 16)
    }
}

struct FrequentlyAskedQuestionList_Previews: PreviewProvider {
    static var previews: some View {
        FrequentlyAskedQuestionList()
    }
}
