//
//  User.swift
//  MsgMeCK
//
//  Created by Benjamin Tincher on 6/16/21.
//

import Foundation
import CloudKit
import MessageKit

struct UserStrings {
    static let name = "name"
    static let conversationIDs = "conversations"
    static let recordType = "User"
}

class User {
    let name: String
    let conversationIDs: [String]
    let ckRecordID: CKRecord.ID
    
    var sender: SenderType {
        return Sender(senderId: ckRecordID.recordName, displayName: name)
    }
    
    init(name: String = "User1", conversationIDs: [String], ckRecordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString)) {
        self.name = name
        self.conversationIDs = conversationIDs
        self.ckRecordID = ckRecordID
    }
}   //  End of Class

extension User {
    
    convenience init?(ckRecord: CKRecord) {
        guard let name = ckRecord[UserStrings.name] as? String,
              let conversationIDs = ckRecord[UserStrings.conversationIDs] as? [String] else { return nil }
        
        self.init(name: name, conversationIDs: conversationIDs, ckRecordID: ckRecord.recordID)
    }
    
}    //  End of Extension

extension CKRecord {
    
    convenience init(user: User) {
        self.init(recordType: UserStrings.recordType, recordID: user.ckRecordID)
        self.setValuesForKeys([
            UserStrings.name : user.name,
            UserStrings.conversationIDs : user.conversationIDs
        ])
    }
    
}   //  End of Extension

extension User: Equatable {
    static func == (lhs: User, rhs: User) -> Bool {
        lhs.ckRecordID == rhs.ckRecordID
    }
}   //  End of Extension


struct Sender: SenderType {
    var senderId: String
    var displayName: String
}   //  End of Struct
