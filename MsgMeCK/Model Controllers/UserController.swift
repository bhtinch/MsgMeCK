//
//  UserController.swift
//  MsgMeCK
//
//  Created by Benjamin Tincher on 6/22/21.
//

import Foundation
import MessageKit
import CloudKit

struct UserController {
    
    static func fetchUserWith(userRef: CKRecord.Reference) -> User? {
        let userRecord = CKRecord(recordType: UserStrings.recordType, recordID: userRef.recordID)
        let user = User(ckRecord: userRecord)
        return user
    }
}
