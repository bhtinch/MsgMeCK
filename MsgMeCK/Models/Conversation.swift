//
//  Conversation.swift
//  MsgMeCK
//
//  Created by Benjamin Tincher on 6/16/21.
//

import Foundation
import CloudKit

struct ConversationStrings {
    static let conversationID = "conversationID"
    static let messageCount = "messageCount"
    static let mostRecentMsgTimestamp = "mostRecentMsgTimestamp"
    static let recordType = "Conversation"
}

class Conversation {
    let conversationID: String
    let messageCount: Int
    let mostRecentMsgTimestamp: Date
    let ckRecordID: CKRecord.ID
    
    init(conversationID: String = UUID().uuidString, messageCount: Int, mostRecentMsgTimestamp: Date, ckRecordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString)) {
        self.conversationID = conversationID
        self.messageCount = messageCount
        self.ckRecordID = ckRecordID
        self.mostRecentMsgTimestamp = mostRecentMsgTimestamp
    }
}   //  End of Class

extension Conversation {
    convenience init?(ckRecord: CKRecord) {
        guard let conversationID = ckRecord[ConversationStrings.conversationID] as? String,
              let messageCount = ckRecord[ConversationStrings.messageCount] as? Int,
              let mostRecentMsgTimestamp = ckRecord[ConversationStrings.mostRecentMsgTimestamp] as? Date else { return nil }
        
        self.init(conversationID: conversationID, messageCount: messageCount, mostRecentMsgTimestamp: mostRecentMsgTimestamp, ckRecordID: ckRecord.recordID)
    }
}   //  End of Extension

extension CKRecord {
    convenience init(convesation: Conversation) {
        self.init(recordType: ConversationStrings.recordType, recordID: convesation.ckRecordID)
        
        self.setValuesForKeys([
            ConversationStrings.conversationID : convesation.conversationID,
            ConversationStrings.messageCount : convesation.messageCount,
            ConversationStrings.mostRecentMsgTimestamp : convesation.mostRecentMsgTimestamp
        ])
    }
}

extension Conversation: Equatable {
    static func == (lhs: Conversation, rhs: Conversation) -> Bool {
        lhs.ckRecordID == rhs.ckRecordID
    }
}
