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
    static let messageText = "messageText"
    static let sentDate = "sentDate"
    static let recordType = "Message"
    static let senderRef = "senderRef"
    static let conversationRef = "conversationRef"
}

struct MessageObjects {
    static let dummySender = Sender(displayName: "Dummy Sender", appleID: CKRecord.ID(recordName: "appleDummyId"), ckRecordID: CKRecord.ID(recordName: "xyzDummyId"))
}

class Message: MessageType {
    let ckRecordID: CKRecord.ID
    let messageText: String
    var sentDate: Date
    
    let senderObject: Sender

    var sender: SenderType {
        return senderObject
    }
    
    var messageId: String {
        return ckRecordID.recordName
    }
    
    var kind: MessageKind {
        return .text(messageText)
    }
    
    init(sentDate: Date = Date(), messageText: String, senderObject: Sender, ckRecordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString)) {
        self.sentDate = sentDate
        self.messageText = messageText
        self.senderObject = senderObject
        self.ckRecordID = ckRecordID
    }
    
    //  convenience from ckRecord
    convenience init?(messageRecord: CKRecord) {
        guard let messageText = messageRecord[MessageStrings.messageText] as? String,
              let sentDate = messageRecord[MessageStrings.sentDate] as? Date,
              let senderRef = messageRecord[MessageStrings.senderRef] as? CKRecord.Reference else { return nil }
        
        let senderRecord = CKRecord(recordType: SenderStrings.recordType, recordID: senderRef.recordID)
        
        guard let senderObject = Sender(senderRecord: senderRecord) else { return nil }
        
        self.init(sentDate: sentDate, messageText: messageText, senderObject: senderObject, ckRecordID: messageRecord.recordID)
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
    convenience init(message: Message, conversationRef: CKRecord.Reference) {
        
        self.init(recordType: MessageStrings.recordType, recordID: message.ckRecordID)
        
        // reference to the user RECORD in CK
        let senderRef = CKRecord.Reference(recordID: message.senderObject.ckRecordID, action: .none)
        
        self.setValuesForKeys([
            MessageStrings.messageText : message.messageText,
            MessageStrings.sentDate : message.sentDate,
            MessageStrings.senderRef : senderRef,
            MessageStrings.conversationRef: conversationRef
        ])
    }
}   //  End of Extension








