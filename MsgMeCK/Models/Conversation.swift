//
//  Conversation.swift
//  MsgMeCK
//
//  Created by Benjamin Tincher on 6/16/21.
//

import Foundation
import CloudKit

struct ConversationStrings {
    static let latestMessageID = "latestMessageID"
    static let latestMessageBody = "latestMessageBody"
    static let latestMessageTimestamp = "latestMessageTimestamp"
    static let senderAId = "senderAId"
    static let senderBId = "senderBId"
    static let messageIDs = "messageIDs"
    static let recordType = "Conversation"
}

class Conversation {
    let latestMessageID: String
    let latestMessageBody: String
    let latestMessageTimestamp: Date
    let senderAId: String
    let senderBId: String
    let messageIDs: [String]
    let ckRecordID: CKRecord.ID
    
    init(latestMessageID: String, latestMessageBody: String, latestMessageTimestamp: Date, senderAId: String, senderBId: String, messageIDs: [String], ckRecordID: CKRecord.ID) {
        self.latestMessageID = latestMessageID
        self.latestMessageBody = latestMessageBody
        self.latestMessageTimestamp = latestMessageTimestamp
        self.senderAId = senderAId
        self.senderBId = senderBId
        self.messageIDs = messageIDs
        self.ckRecordID = ckRecordID
    }
    
    ///convenience from Message object - used to first create the Conversation upon first message
    convenience init(latestMessage: Message, senderBId: String, ckRecordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString)) {
        let latestMessageID = latestMessage.messageId
        let latestMessageBody = latestMessage.messageText
        let latestMessageTimestamp = latestMessage.sentDate
        let senderAId = latestMessage.sender.senderId
        let messageIDs = [latestMessage.ckRecordID.recordName]
        
        self.init(latestMessageID: latestMessageID, latestMessageBody: latestMessageBody, latestMessageTimestamp: latestMessageTimestamp, senderAId: senderAId, senderBId: senderBId, messageIDs: messageIDs, ckRecordID: ckRecordID)
    }
    
    //  convenience from ckRecord object
    convenience init?(ckRecord: CKRecord) {
        guard let latestMessageID = ckRecord[ConversationStrings.latestMessageID] as? String,
              let latestMessageBody = ckRecord[ConversationStrings.latestMessageBody] as? String,
              let latestMessageTimestamp = ckRecord[ConversationStrings.latestMessageTimestamp] as? Date,
              let senderAId = ckRecord[ConversationStrings.senderAId] as? String,
              let senderBId = ckRecord[ConversationStrings.senderBId] as? String,
              let messageIDs = ckRecord[ConversationStrings.messageIDs] as? [String] else { return nil }
        
        self.init(latestMessageID: latestMessageID, latestMessageBody: latestMessageBody, latestMessageTimestamp: latestMessageTimestamp, senderAId: senderAId, senderBId: senderBId, messageIDs: messageIDs, ckRecordID: ckRecord.recordID)
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
    convenience init(convesation: Conversation) {
        self.init(recordType: ConversationStrings.recordType, recordID: convesation.ckRecordID)
        
        self.setValuesForKeys([
            ConversationStrings.latestMessageID : convesation.latestMessageID,
            ConversationStrings.latestMessageBody : convesation.latestMessageBody,
            ConversationStrings.latestMessageTimestamp : convesation.latestMessageTimestamp,
            ConversationStrings.senderAId : convesation.senderAId,
            ConversationStrings.senderBId : convesation.senderBId
        ])
    }
}   //  End of Extension


