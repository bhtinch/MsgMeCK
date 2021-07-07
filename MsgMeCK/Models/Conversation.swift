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
    var senderA: Sender? = nil
    var senderB: Sender? = nil
    let senderARef: CKRecord.Reference
    let senderBRef: CKRecord.Reference
    let ckRecordID: CKRecord.ID
        
    init(senderARef: CKRecord.Reference, senderBRef: CKRecord.Reference, ckRecordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString)) {
        self.senderARef = senderARef
        self.senderBRef = senderBRef
        self.ckRecordID = ckRecordID
    }
    
    //  convenience from ckRecord object
    convenience init?(conversationRecord: CKRecord) {
        guard let senderARef = conversationRecord[ConversationStrings.senderARef] as? CKRecord.Reference,
              let senderBRef = conversationRecord[ConversationStrings.senderBRef] as? CKRecord.Reference else { return nil }
        
        self.init(senderARef: senderARef, senderBRef: senderBRef, ckRecordID: conversationRecord.recordID)
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
        
        let senderARef = CKRecord.Reference(recordID: conversation.senderARef.recordID, action: .none)
        let senderBRef = CKRecord.Reference(recordID: conversation.senderBRef.recordID, action: .none)
        
        self.setValuesForKeys([
            ConversationStrings.senderARef : senderARef,
            ConversationStrings.senderBRef : senderBRef
        ])
    }
}   //  End of Extension


