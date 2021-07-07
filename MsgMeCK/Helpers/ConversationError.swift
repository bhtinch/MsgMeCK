//
//  ConversationError.swift
//  MsgMeCK
//
//  Created by Benjamin Tincher on 6/16/21.
//

import Foundation

enum ConversationError: LocalizedError {
    case thrownError(Error)
    case fetchError
    case createError
}
