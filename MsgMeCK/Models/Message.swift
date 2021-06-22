//
//  Message.swift
//  MsgMeCK
//
//  Created by Benjamin Tincher on 6/16/21.
//

import Foundation
import CloudKit
import MessageKit

struct MessageStrings {
    static let messageID = "messageID"
    static let userReference = "userReference"
    static let sentDate = "sentDate"
    static let messageText = "messageText"
    static let recordType = "Message"
}

class Message: MessageType {
    let messageId: String
    let sentDate: Date
    let user: User
    let ckRecordID: CKRecord.ID
    let messageText: String
    
    var sender: SenderType {
        return user.sender
    }
    
    var kind: MessageKind {
        return .text(messageText)
    }
    
    init(messageID: String, sentDate: Date, user: User, messageText: String, ckRecordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString)) {
        self.messageId = messageID
        self.sentDate = sentDate
        self.user = user
        self.messageText = messageText
        self.ckRecordID = ckRecordID
    }
    
    
    //  convenience from ckRecord
    convenience init?(ckRecord: CKRecord) {
        guard let messageID = ckRecord[MessageStrings.messageID] as? String,
              let userRef = ckRecord[MessageStrings.userReference] as? CKRecord.Reference,
              let sentDate = ckRecord[MessageStrings.sentDate] as? Date,
              let messageText = ckRecord[MessageStrings.messageText] as? String else { return nil }
        
        guard let user = UserController.fetchUserWith(userRef: userRef) else { return nil }
        
        self.init(messageID: messageID, sentDate: sentDate, user: user, messageText: messageText, ckRecordID: ckRecord.recordID)
    }
}   //  End of Class

extension Message: Equatable {
    static func == (lhs: Message, rhs: Message) -> Bool {
        lhs.ckRecordID == rhs.ckRecordID
    }
}   //  End of Extension


//  MARK: - CKRECORD
extension CKRecord {
    //  convenience from Message
    convenience init(message: Message) {
        
        self.init(recordType: MessageStrings.recordType, recordID: message.ckRecordID)
        
        // reference to the user RECORD in CK
        let userRef = CKRecord.Reference(recordID: message.ckRecordID, action: .none)
        
        self.setValuesForKeys([
            MessageStrings.messageID : message.messageId,
            MessageStrings.messageText : message.messageText,
            MessageStrings.sentDate : message.sentDate,
            MessageStrings.userReference : userRef
        ])
    }
}   //  End of Extension








