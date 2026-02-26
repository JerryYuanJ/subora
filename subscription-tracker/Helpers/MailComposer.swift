//
//  MailComposer.swift
//  subscription-tracker
//
//  Helper for composing and sending emails
//

import SwiftUI
import MessageUI

/// UIViewControllerRepresentable wrapper for MFMailComposeViewController
struct MailComposer: UIViewControllerRepresentable {
    @Environment(\.dismiss) private var dismiss
    
    let recipients: [String]
    let subject: String
    let body: String
    
    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let composer = MFMailComposeViewController()
        composer.mailComposeDelegate = context.coordinator
        composer.setToRecipients(recipients)
        composer.setSubject(subject)
        composer.setMessageBody(body, isHTML: false)
        return composer
    }
    
    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {
        // No updates needed
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(dismiss: dismiss)
    }
    
    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        let dismiss: DismissAction
        
        init(dismiss: DismissAction) {
            self.dismiss = dismiss
        }
        
        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            dismiss()
        }
    }
}

/// Helper to check if mail is available
extension MailComposer {
    static var canSendMail: Bool {
        MFMailComposeViewController.canSendMail()
    }
}
