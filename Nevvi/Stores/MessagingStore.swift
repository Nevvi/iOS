//
//  MessagingStore.swift
//  Nevvi
//
//  Created by Tyler Standal on 1/28/24.
//

import Foundation
import MessageUI

class MessagingStore : NSObject, ObservableObject, MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate  {
    var textComposeVC = MFMessageComposeViewController()
    var mailComposeVC = MFMailComposeViewController()

    override init() {
        super.init()
        textComposeVC.messageComposeDelegate = self
        mailComposeVC.mailComposeDelegate = self
    }
    
    func canSendText() -> Bool {
        return MFMessageComposeViewController.canSendText()
    }
    
    func canSendMail() -> Bool {
        return MFMailComposeViewController.canSendMail()
    }
    
    func loadSms(recipient: String) -> Void {
        self.textComposeVC = MFMessageComposeViewController()
        self.textComposeVC.messageComposeDelegate = self
        self.textComposeVC.recipients = [recipient]
    }
    
    func loadEmail(sender: String, recipient: String) -> Void {
        self.mailComposeVC = MFMailComposeViewController()
        self.mailComposeVC.mailComposeDelegate = self
        self.mailComposeVC.setPreferredSendingEmailAddress(sender)
        self.mailComposeVC.setToRecipients([recipient])
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) { controller.dismiss(animated: true)
    }
}
