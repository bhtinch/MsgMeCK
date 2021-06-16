//
//  ConversationViewController.swift
//  MsgMeCK
//
//  Created by Benjamin Tincher on 6/16/21.
//

import UIKit
import MessageKit
import CloudKit

class ConversationViewController: MessagesViewController {
    
    //  MARK: - PROPERTIES
    var messages: [Message] = []
    var user: User?
    var conversationID: String?

    //  MARK: - LIFECYLES
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    //  MARK: - METHODS
    
}   //  End of Class

//  MARK: - MESSAGES DATASOURCE AND DELEGATES
extension ConversationViewController: MessagesDataSource, MessagesDisplayDelegate {
    func currentSender() -> SenderType {
        guard let user = user else { return Sender(senderId: "xxxxxx", displayName: "unknown sender") }
        return user.sender
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.row]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
}   //  End of Extension
