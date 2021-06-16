//
//  User.swift
//  MsgMeCK
//
//  Created by Benjamin Tincher on 6/16/21.
//

import Foundation
import CloudKit

struct UserStrings {
    static let name = "name"
    static let conversations = "conversations"
    static let recordType = "User"
}

class User {
    let name: String
    let conversations: [Conversation]
    let ckRecordID: CKRecord.ID
    
    init(name: String = "User1", conversations: [Conversation], ckRecordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString)) {
        self.name = name
        self.conversations = conversations
        self.ckRecordID = ckRecordID
    }
}   //  End of Class

extension User {
    
    convenience init?(ckRecord: CKRecord) {
        guard let name = ckRecord[UserStrings.name] as? String,
              let conversations = ckRecord[UserStrings.conversations] as? [Conversation] else { return nil }
        
        self.init(name: name, conversations: conversations, ckRecordID: ckRecord.recordID)
    }
    
}    //  End of Extension

extension CKRecord {
    
    convenience init(user: User) {
        self.init(recordType: UserStrings.recordType, recordID: user.ckRecordID)
        self.setValuesForKeys([
            UserStrings.name : user.name,
            UserStrings.conversations : user.conversations
        ])
    }
    
}   //  End of Extension

extension User: Equatable {
    static func == (lhs: User, rhs: User) -> Bool {
        lhs.ckRecordID == rhs.ckRecordID
    }
}   //  End of Extension
