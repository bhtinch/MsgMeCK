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
    var otherSenderRef: CKRecord.Reference?
    var otherSender: Sender?
    var conversation: Conversation?
    
    //  MARK: - LIFECYLES
    override func viewDidLoad() {
        super.viewDidLoad()
        configureMessageCollectionView()
        configureMessageInputBar()
        setObserver()
        
        self.title = otherSender?.displayName
        
        fetchConversation()
    }
    
    //  MARK: - SETUP METHODS
    func configureMessageCollectionView() {
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messageCellDelegate = self
        
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

        messageInputBar.setLeftStackViewWidthConstant(to: 35, animated: true)

        self.messageInputBar = messageInputBar
    }
    
    func setObserver() {
        print("setting message observer...")
        
        CKController.setNewMessageObserver(observeObject: ObserveObjects.shared) { _ in
            self.fetchMessages()
        }
    }
    
    //  MARK: - NEW CONVERSATION METHODS
    func createNewConversation() {
        guard let otherSenderRef = otherSenderRef else { return }
        CKController.createNewConversationWith(otherSenderRef: otherSenderRef) { conversation in
            guard let conversation = conversation else { return }
            self.conversation = conversation
            CKController.conversations.append(conversation)
            
            CKController.subscribeToNewMessagesTo(conversation: conversation)
            self.messageInputBar.didSelectSendButton()
        }
    }
    
    //  MARK: - EXISTING CONVERSATION METHODS
    func fetchConversation() {
        guard let otherSenderRef = otherSenderRef,
              let selfSenderRef = CKController.selfSenderRef else { return }
        
        CKController.fetchConversationWith(selfSenderRef: selfSenderRef, otherSenderRef: otherSenderRef) { result in
            switch result {
            case .success(let conversation):
                if let conversation = conversation {
                    print("\nSuccessfully fetched conversation with ID: \(conversation.ckRecordID.recordName)\n")
                    self.conversation = conversation
                    self.fetchMessages()
                } else {
                    CKController.messages = []
                }
            case .failure(let error):
                print("***Error*** in Function: \(#function)\n\nError: \(error)\n\nDescription: \(error.localizedDescription)")
            }
        }
    }
    
    func fetchMessages() {
        guard let conversation = conversation,
              let otherSender = otherSender else { return }
        
        CKController.fetchMessagesFor(conversation: conversation) { messages in
            CKController.messages = messages
            
            CKController.applySendersTo(messages: messages, isAppending: false, otherSender: otherSender)
            self.messagesCollectionView.reloadData()
            self.messagesCollectionView.scrollToLastItem(animated: true)

        }
    }
}   //  End of Class

//  MARK: - MESSAGEKIT INPUT BAR DELEGATE
extension ConversationViewController: InputBarAccessoryViewDelegate {
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        if conversation == nil {
            self.createNewConversation()
            
        } else {
            CKController.sendNewMessageTo(conversation: conversation!, text: text) { message in
                guard let message = message,
                      let otherSender = self.otherSender else { return }
                
                CKController.applySendersTo(messages: [message], isAppending: true, otherSender: otherSender)
                
                print("successully saved message with id: \(message.ckRecordID.recordName) and text: \(message.messageText)")
                self.messagesCollectionView.reloadData()
                self.resetInputBar()
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
        return CKController.messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return CKController.messages.count
    }
}   //  End of Extension

extension ConversationViewController: MessageCellDelegate, MessagesLayoutDelegate {
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        
        let initials = message.sender.displayName.first ?? "?"
        avatarView.backgroundColor = .link
        
        if message.sender.senderId == CKController.selfSenderRef?.recordID.recordName {
            avatarView.backgroundColor = #colorLiteral(red: 0.3236978054, green: 0.1063579395, blue: 0.574860394, alpha: 1)
        }
        
        let avatar = Avatar(image: nil, initials: initials.description)
        avatarView.set(avatar: avatar)
    }
}   //  End of Extension
