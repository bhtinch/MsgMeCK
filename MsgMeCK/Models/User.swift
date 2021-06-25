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
    static let recordType = "Users"
}

class User {
    let ckRecordID: CKRecord.ID

    init(ckRecordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString)) {
        self.ckRecordID = ckRecordID
    }

    convenience init?(userRecord: CKRecord) {
        self.init(ckRecordID: userRecord.recordID)
    }
}   //  End of Class

extension User: Equatable {
    static func == (lhs: User, rhs: User) -> Bool {
        lhs.ckRecordID == rhs.ckRecordID
    }
}   //  End of Extension


//  MARK: - CKRECORD
extension CKRecord {
    convenience init(user: User) {
        self.init(recordType: UserStrings.recordType, recordID: user.ckRecordID)
    }
}   //  End of Extension



