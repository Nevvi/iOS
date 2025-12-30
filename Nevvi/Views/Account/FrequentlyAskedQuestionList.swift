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
            response: "You are not only in charge of who can see your data, but what each person can see as well. You can create new permission groups on the settings page to restrict what information some users see."
        ),
        QuestionResponse(
            question: "Why does Nevvi need access to my contacts?",
            response: "By giving Nevvi access to your contacts, we give you the option to sync all updated connection information to your phone's contact book. We also use your contacts to give you the ability to invite users to join Nevvi."
        ),
        QuestionResponse(
            question: "How do I find new connections?",
            response: "On the Connections tab when you search for users we will show you both users you are already connected with and users you can request to connect with. The search tab will also show you recommended connections based on your network."
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
        VStack(alignment: .leading) {
            Text("Frequently Asked Questions")
                .font(.system(size: 26, weight: .bold))
                .padding(.horizontal, 20)
            
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
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct FrequentlyAskedQuestionList_Previews: PreviewProvider {
    static var previews: some View {
        FrequentlyAskedQuestionList()
    }
}
