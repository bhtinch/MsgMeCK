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

    //  MARK: - LIFECYLES
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    //  MARK: - METHODS
    
}   //  End of Class

//  MARK: - MESSAGES DATASOURCE AND DELEGATES
extension ConversationViewController: MessagesDataSource, MessagesDisplayDelegate {
    func currentSender() -> SenderType {
        return currentSender()
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return 0
    }
}   //  End of Extension
