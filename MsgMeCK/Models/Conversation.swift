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
    static let selfSenderRef = "selfUserRef"
    static let otherSenderRef = "otherUserRef"
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
        guard let selfSenderRef = conversationRecord[ConversationStrings.selfSenderRef] as? CKRecord.Reference,
              let otherSenderRef = conversationRecord[ConversationStrings.otherSenderRef] as? CKRecord.Reference else { return nil }
                
        let selfSenderRecord = CKRecord(recordType: SenderStrings.recordType, recordID: selfSenderRef.recordID)
        let otherSenderRecord = CKRecord(recordType: SenderStrings.recordType, recordID: otherSenderRef.recordID)

        guard let selfSender = Sender(senderRecord: selfSenderRecord),
              let otherSender = Sender(senderRecord: otherSenderRecord) else { return nil }
        
        self.init(selfSender: selfSender, otherSender: otherSender, ckRecordID: conversationRecord.recordID)
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
            ConversationStrings.selfSenderRef : selfUserRef,
            ConversationStrings.otherSenderRef : otherUserRef
        ])
    }
}   //  End of Extension


