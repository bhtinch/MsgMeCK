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
    static let senderARef = "senderARef"
    static let senderBRef = "senderBRef"
    static let recordType = "Conversation"
}

class Conversation {
    let senderA: Sender
    let senderB: Sender
    let ckRecordID: CKRecord.ID
        
    init(senderA: Sender, senderB: Sender, ckRecordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString)) {
        self.senderA = senderA
        self.senderB = senderB
        self.ckRecordID = ckRecordID
    }
    
    //  convenience from ckRecord object
    convenience init?(conversationRecord: CKRecord) {
        guard let senderARef = conversationRecord[ConversationStrings.senderARef] as? CKRecord.Reference,
              let senderBRef = conversationRecord[ConversationStrings.senderBRef] as? CKRecord.Reference else { return nil }
                
        let senderARecord = CKRecord(recordType: SenderStrings.recordType, recordID: senderARef.recordID)
        let senderBRecord = CKRecord(recordType: SenderStrings.recordType, recordID: senderBRef.recordID)

        guard let senderA = Sender(senderRecord: senderARecord),
              let senderB = Sender(senderRecord: senderBRecord) else { return nil }
        
        self.init(senderA: senderA, senderB: senderB, ckRecordID: conversationRecord.recordID)
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
        
        let senderARef = CKRecord.Reference(recordID: conversation.senderA.ckRecordID, action: .none)
        let senderBRef = CKRecord.Reference(recordID: conversation.senderB.ckRecordID, action: .none)
        
        self.setValuesForKeys([
            ConversationStrings.senderARef : senderARef,
            ConversationStrings.senderBRef : senderBRef
        ])
    }
}   //  End of Extension


