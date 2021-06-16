//
//  CKController.swift
//  MsgMeCK
//
//  Created by Benjamin Tincher on 6/16/21.
//

import Foundation
import CloudKit
import MessageKit

struct CKController {
    static let privateDB = CKContainer.default().privateCloudDatabase
    static let publicDB = CKContainer.default().publicCloudDatabase
}
