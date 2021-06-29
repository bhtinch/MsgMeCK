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
    static let dummySender = Sender(displayName: "Dummy Sender", appleID: CKRecord.Reference(recordID: CKRecord.ID(recordName: "appleDummyId"), action: .none), ckRecordID: CKRecord.ID(recordName: "xyzDummyId"))
}

class Message: MessageType {
    let ckRecordID: CKRecord.ID
    let messageText: String
    var sentDate: Date
    
    let senderObjectRef: CKRecord.Reference
    
    var senderObject: Sender? = nil

    var sender: SenderType {
        return senderObject ?? MessageObjects.dummySender
    }
    
    var messageId: String {
        return ckRecordID.recordName
    }
    
    var kind: MessageKind {
        return .text(messageText)
    }
    
    init(sentDate: Date = Date(), messageText: String, senderObjectRef: CKRecord.Reference, ckRecordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString)) {
        self.sentDate = sentDate
        self.messageText = messageText
        self.senderObjectRef = senderObjectRef
        self.ckRecordID = ckRecordID
    }
    
    //  convenience from ckRecord
    convenience init?(messageRecord: CKRecord) {
        guard let messageText = messageRecord[MessageStrings.messageText] as? String,
              let sentDate = messageRecord[MessageStrings.sentDate] as? Date,
              let senderObjectRef = messageRecord[MessageStrings.senderRef] as? CKRecord.Reference else { return nil }
        
        self.init(sentDate: sentDate, messageText: messageText, senderObjectRef: senderObjectRef, ckRecordID: messageRecord.recordID)
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
        let senderRef = CKRecord.Reference(recordID: message.senderObjectRef.recordID, action: .none)
        
        self.setValuesForKeys([
            MessageStrings.messageText : message.messageText,
            MessageStrings.sentDate : message.sentDate,
            MessageStrings.senderRef : senderRef,
            MessageStrings.conversationRef: conversationRef
        ])
    }
}   //  End of Extension








