//
//  CKError.swift
//  MsgMeCK
//
//  Created by Benjamin Tincher on 6/24/21.
//

import Foundation

enum CKError: LocalizedError {
    case thrownError(Error)
    case fetchError
    case createError
}
