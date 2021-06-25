//
//  Conversation.swift
//  MsgMeCK
//
//  Created by Benjamin Tincher on 6/16/21.
//

import Foundation
import CloudKit
import MessageKit

struct ConversationStrings {
    static let selfUserRef = "selfUserRef"
    static let otherUserRef = "otherUserRef"
    static let recordType = "Conversation"
}

class Conversation {
    let selfSender: Sender
    let otherSender: Sender
    let ckRecordID: CKRecord.ID
        
    init(selfSender: Sender, otherSender: Sender, ckRecordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString)) {
        self.selfSender = selfSender
        self.otherSender = otherSender
        self.ckRecordID = ckRecordID
    }
    
    //  convenience from ckRecord object
    convenience init?(conversationRecord: CKRecord) {
        guard let selfUserRef = conversationRecord[ConversationStrings.selfUserRef] as? CKRecord.Reference,
              let otherUserRef = conversationRecord[ConversationStrings.otherUserRef] as? CKRecord.Reference else { return nil }
        
        let selfUserRecord = CKRecord(recordType: UserStrings.recordType, recordID: selfUserRef.recordID)
        let otherUserRecord = CKRecord(recordType: UserStrings.recordType, recordID: otherUserRef.recordID)
        
        guard let selfUser = Sender(senderRecord: selfUserRecord),
              let otherUser = Sender(senderRecord: otherUserRecord) else { return nil }
        
        self.init(selfSender: selfUser, otherSender: otherUser, ckRecordID: conversationRecord.recordID)
    }
}   //  End of Class

extension Conversation: Equatable {
    static func == (lhs: Conversation, rhs: Conversation) -> Bool {
        lhs.ckRecordID == rhs.ckRecordID
    }
}   //  End of Extension


//  MARK: - CKRECORD
extension CKRecord {
    //  convenience from Conversation object
    convenience init(conversation: Conversation) {
        self.init(recordType: ConversationStrings.recordType, recordID: conversation.ckRecordID)
        
        let selfUserRef = CKRecord.Reference(recordID: conversation.selfSender.ckRecordID, action: .none)
        let otherUserRef = CKRecord.Reference(recordID: conversation.otherSender.ckRecordID, action: .none)
        
        self.setValuesForKeys([
            ConversationStrings.selfUserRef : selfUserRef,
            ConversationStrings.otherUserRef : otherUserRef
        ])
    }
}   //  End of Extension


