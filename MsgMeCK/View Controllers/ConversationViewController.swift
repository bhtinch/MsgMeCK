//
//  ConversationViewController.swift
//  MsgMeCK
//
//  Created by Benjamin Tincher on 6/16/21.
//

import UIKit
import MessageKit
import CloudKit
import InputBarAccessoryView

class ConversationViewController: MessagesViewController {
    //  MARK: - PROPERTIES
    var messages: [Message] = []
    var otherSender: Sender?
    var conversationRef: CKRecord.Reference?
    
    //  MARK: - LIFECYLES
    override func viewDidLoad() {
        super.viewDidLoad()
        configureMessageCollectionView()
        //configureMessageInputBar()
        
        if conversationRef != nil {
            fetchConversationRef()
        }
    }
    
    //  MARK: - METHODS
    func configureMessageCollectionView() {
        
        messagesCollectionView.messagesDataSource = self
        //messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        //messagesCollectionView.messageCellDelegate = self
        //messagesCollectionView.messagesLayoutDelegate = self
        
        scrollsToLastItemOnKeyboardBeginsEditing = true // default false
        maintainPositionOnKeyboardFrameChanged = true // default false
        showMessageTimestampOnSwipeLeft = true // default false
    }
    
    func configureMessageInputBar() {
        let messageInputBar = messageInputBar
        messageInputBar.delegate = self
        messageInputBar.inputTextView.tintColor = .blue
        messageInputBar.sendButton.setTitleColor(.blue, for: .normal)
        messageInputBar.sendButton.setTitleColor(
            UIColor.blue.withAlphaComponent(0.3),
            for: .highlighted
        )

//        let camera = makeButton(named: "ic_camera")
//        camera.tintColor = .darkGray
//        camera.onTouchUpInside { (item) in
//            print("camera tapped.")
//            self.presentImageAlert()
//        }

        messageInputBar.setLeftStackViewWidthConstant(to: 35, animated: true)
        //messageInputBar.setStackViewItems([camera], forStack: .left, animated: false)
        //attachmentManager.delegate = messageInputBar
        //messageInputBar.inputPlugins = [attachmentManager]

        self.messageInputBar = messageInputBar
    }
    
    func fetchConversationRef() {
        guard let otherSender = otherSender,
              let selfSender = CKController.selfSender else { return }
        
        let selfSenderRef = CKRecord.Reference(recordID: selfSender.ckRecordID, action: .none)
        let otherSenderRef = CKRecord.Reference(recordID: otherSender.ckRecordID, action: .none)
        
        CKController.fetchConversationWith(selfSenderRef: selfSenderRef, otherSenderRef: otherSenderRef) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let conversation):
                    if let conversation = conversation {
                        let conversationRef = CKRecord.Reference(recordID: conversation.ckRecordID, action: .none)
                        self.conversationRef = conversationRef
                        self.fetchMessages()
                    }
                case .failure(let error):
                    print("***Error*** in Function: \(#function)\n\nError: \(error)\n\nDescription: \(error.localizedDescription)")
                }
            }
        }
    }
    
    
    //  BenTin - DOES THIS NEED TO BE A LISTENER AND NOT JUST A FETCH???
    func fetchMessages() {
        guard let conversationRef = conversationRef else { return }
        
    }
    
}   //  End of Class

//  MARK: - MESSAGEKIT INPUT BAR DELEGATE
extension ConversationViewController: InputBarAccessoryViewDelegate {
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        CKController.sendNewMessageWith(conversationRef: self.conversationRef, otherSender: self.otherSender, text: text) { succes in
            DispatchQueue.main.async {
                if succes {
                    self.resetInputBar()
                } else {
                    Alerts.presentAlertWith(title: "Whoops!", message: "Your message could not be sent.  Please try again.", sender: self)
                }
            }
        }
    }
    
    func resetInputBar() {
        messageInputBar.inputTextView.text = String()
        messageInputBar.invalidatePlugins()
        // Send button activity animation
        messageInputBar.sendButton.startAnimating()
        messageInputBar.inputTextView.placeholder = "Sending..."
        // Resign first responder for iPad split view
        messageInputBar.inputTextView.resignFirstResponder()
        DispatchQueue.global(qos: .default).async {
            // fake send request task
            sleep(1)
            DispatchQueue.main.async { [weak self] in
                self?.messageInputBar.sendButton.stopAnimating()
                self?.messageInputBar.inputTextView.placeholder = "Aa"
                self?.messagesCollectionView.scrollToLastItem(animated: true)
            }
        }
    }
} // END OF EXTENSION


//  MARK: - MESSAGES DATASOURCE AND DELEGATES
extension ConversationViewController: MessagesDataSource, MessagesDisplayDelegate {
    func currentSender() -> SenderType {
        guard let selfSender = CKController.selfSender else { return MessageObjects.dummySender }
        return selfSender
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.row]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
}   //  End of Extension
