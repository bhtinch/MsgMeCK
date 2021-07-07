//
//  ObserveObjects.swift
//  MsgMeCK
//
//  Created by Benjamin Tincher on 7/5/21.
//

import Foundation

class ObserveObjects: NSObject {
    static var shared = ObserveObjects()
    
    @objc dynamic var newConversation = false
    @objc dynamic var newMessage = false
}
