//
//  Profile.swift
//  MsgMeCK
//
//  Created by Benjamin Tincher on 6/24/21.
//

import Foundation
import CloudKit
import MessageKit

struct SenderStrings  {
    static let recordType = "Sender"
    static let displayName = "displayName"
    static let userRef = "userRef"
    static let appleID = "appleID"
}

class Sender: SenderType {
    let displayName: String
    let ckRecordID: CKRecord.ID
    let appleID: CKRecord.ID
    
    var senderId: String {
        return ckRecordID.recordName
    }
    
    init(displayName: String, appleID: CKRecord.ID, ckRecordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString)) {
        self.displayName = displayName
        self.appleID = appleID
        self.ckRecordID = ckRecordID
    }
    
    convenience init?(senderRecord: CKRecord) {
        guard let displayName = senderRecord[SenderStrings.displayName] as? String,
              let appleIDString = senderRecord[SenderStrings.appleID] as? String else { return nil }
        
        let appleID = CKRecord.ID(recordName: appleIDString)
        
        self.init(displayName: displayName, appleID: appleID, ckRecordID: senderRecord.recordID)
    }
}

extension CKRecord {
    convenience init(sender: Sender) {
        self.init(recordType: SenderStrings.recordType, recordID: sender.ckRecordID)
        
        self.setValuesForKeys([
            SenderStrings.displayName : sender.displayName,
            SenderStrings.appleID : sender.appleID.recordName
        ])
    }
}
