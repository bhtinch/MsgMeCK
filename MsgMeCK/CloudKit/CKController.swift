//
//  CKController.swift
//  MsgMeCK
//
//  Created by Benjamin Tincher on 6/16/21.
//

import Foundation
import CloudKit
import MessageKit

struct CKController {
    static let privateDB = CKContainer.default().privateCloudDatabase
    static let publicDB = CKContainer.default().publicCloudDatabase
    
    static let messages: [Message] = []
    static let conversations: [Conversation] = []
    
    //  MARK: - USER FUNCTIONS
    
    
    //  MARK: - CONVERSATION FUNCTIONS
    static func createNewConversationWith() {
        
    }
    
    static func fetchConversationWith(conversationID: String) {
        
    }
    
    //  MARK: - MESSAGE FUNCTIONS
    static func createNewMessageWith() {
        
    }
    
    static func fetchMessageWith(messageID: String, completion: @escaping(Result<Message, CKError>) -> Void) {
        
    }
}   //  End of Struct
