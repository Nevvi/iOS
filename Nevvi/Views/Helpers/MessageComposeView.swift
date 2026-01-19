//
//  MessageComposeView.swift
//  Nevvi
//
//  Created by Tyler Standal on 1/3/26.
//

import SwiftUI
import MessageUI

struct MessageComposeView: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    var recipients: [String]
    var body: String
    var completion: (MessageComposeResult) -> Void

    func makeUIViewController(context: Context) -> MFMessageComposeViewController {
        print("MAKING UI VIEW CONTROLLER")
        print(body)
        let controller = MFMessageComposeViewController()
        controller.messageComposeDelegate = context.coordinator
        controller.recipients = recipients
        controller.body = body
        return controller
    }

    func updateUIViewController(_ uiViewController: MFMessageComposeViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    class Coordinator: NSObject, MFMessageComposeViewControllerDelegate {
        var parent: MessageComposeView

        init(parent: MessageComposeView) {
            self.parent = parent
        }

        func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
            parent.completion(result)            
            parent.isPresented = false
        }
    }
}
