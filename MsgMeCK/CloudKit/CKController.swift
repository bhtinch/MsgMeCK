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
    
    static let messages: [Message] = []
    static let conversations: [Conversation] = []
    static var selfSender: Sender?
    
    //  MARK: - USER FUNCTIONS
    static func fetchCurrentUser(completion: @escaping (CKRecord?) -> Void) {
        CKContainer.default().fetchUserRecordID { recordID, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("***Error*** in Function: \(#function)\n\nError: \(error)\n\nDescription: \(error.localizedDescription)")
                    completion(nil)
                }
                guard let recordID = recordID else { return completion(nil) }
                print("iCloud ID: " + recordID.recordName)

                let record = CKRecord(recordType: SenderStrings.recordType, recordID: recordID)

                completion(record)
            }
        }
    }
    
    static func fetchSenderByUserRefOrAppleID(userRef: CKRecord.Reference?, appleID: String?, completion: @escaping(Sender?) -> Void) {
        var predicate: NSPredicate?
        
        if let userRef = userRef {
            predicate = NSPredicate(format: "%K == %@", SenderStrings.appleID, userRef.recordID.recordName)
        } else if let appleID = appleID {
            predicate = NSPredicate(format: "%K == %@", SenderStrings.appleID, appleID)
        }
        
        guard let predicate = predicate else { return completion(nil) }
        
        let query = CKQuery(recordType: SenderStrings.recordType, predicate: predicate)
        
        publicDB.perform(query, inZoneWith: nil) { (records, error) in
            DispatchQueue.main.async {
                if let error = error {
                    print("***Error*** in Function: \(#function)\n\nError: \(error)\n\nDescription: \(error.localizedDescription)")
                    return completion(nil)
                }
                
                guard let records = records,
                      let senderRecord = records.first,
                      let sender = Sender(senderRecord: senderRecord) else { return completion(nil) }
                
                completion(sender)
            }
        }
    }
    
    static func saveNewSenderWith(appleID: CKRecord.ID, displayName: String, completion: @escaping(Sender?) -> Void) {
        let sender = Sender(displayName: displayName, appleID: appleID)
        
        let newSenderRecord = CKRecord(sender: sender)
        
        publicDB.save(newSenderRecord) { record, error in
            if let error = error {
                print("***Error*** in Function: \(#function)\n\nError: \(error)\n\nDescription: \(error.localizedDescription)")
                return completion(nil)
            }
            
            guard let senderRecord = record,
                  let sender = Sender(senderRecord: senderRecord) else { return completion(nil) }
            
            self.selfSender = sender
            completion(sender)
        }
    }
    
    static func fetchAllSenders(completion: @escaping(Result<[Sender], CKError>) -> Void ) {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: SenderStrings.recordType, predicate: predicate)
        
        publicDB.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error {
                print("***Error*** in Function: \(#function)\n\nError: \(error)\n\nDescription: \(error.localizedDescription)")
                return completion(.failure(.fetchError))
            }
            
            guard var records = records else { return completion(.success([])) }
            records.sort { ($0[SenderStrings.displayName] as! String) < ($1[SenderStrings.displayName] as! String) }
            let senders = records.compactMap { Sender(senderRecord: $0) }
            completion(.success(senders))
        }
    }
    
    
    //  MARK: - CONVERSATION FUNCTIONS
    static func createNewConversationWith(otherSender: Sender, completion: @escaping(Result<Conversation, CKError>) -> Void ) {
        guard let selfSender = selfSender else { return completion(.failure(.createError)) }
        let conversation = Conversation(selfSender: selfSender, otherSender: otherSender)
        
        let conversationRecord = CKRecord(conversation: conversation)
        
        publicDB.save(conversationRecord) { record, error in
            if let error = error {
                print("***Error*** in Function: \(#function)\n\nError: \(error)\n\nDescription: \(error.localizedDescription)")
                return completion(.failure(.createError))
            }
            
            guard let record = record,
                  let conversation = Conversation(conversationRecord: record) else { return completion(.failure(.createError)) }
            
            completion(.success(conversation))
        }
    }
    
    static func fetchAllConversationsWith(senderRef: CKRecord.Reference, completion: @escaping(Result<[Conversation], CKError>) -> Void ) {
        
        let predicate = NSPredicate(format: "%K == %@", ConversationStrings.selfSenderRef, senderRef)
        
        let query = CKQuery(recordType: ConversationStrings.recordType, predicate: predicate)
        
        publicDB.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error {
                print("***Error*** in Function: \(#function)\n\nError: \(error)\n\nDescription: \(error.localizedDescription)")
                return completion(.failure(.fetchError))
            }
            
            guard var records = records else { return completion(.success([])) }
            
            records.sort { $0.modificationDate! < $1.modificationDate! }
            
            let convos = records.compactMap { Conversation(conversationRecord: $0) }
            return completion(.success(convos))
        }
    }
    
    static func fetchConversationWith(selfSenderRef: CKRecord.Reference, otherSenderRef: CKRecord.Reference, completion: @escaping(Result<Conversation?, CKError>) -> Void ) {
        let predA = NSPredicate(format: "%K == %@ AND %K == %@", ConversationStrings.selfSenderRef, selfSenderRef, ConversationStrings.otherSenderRef, otherSenderRef)
        let predB = NSPredicate(format: "%K == %@ AND %K == %@", ConversationStrings.selfSenderRef, otherSenderRef, ConversationStrings.otherSenderRef, selfSenderRef)

        let compoundPred = NSCompoundPredicate(orPredicateWithSubpredicates: [predA, predB])
        
        let query = CKQuery(recordType: ConversationStrings.recordType, predicate: compoundPred)
        
        publicDB.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error {
                print("***Error*** in Function: \(#function)\n\nError: \(error)\n\nDescription: \(error.localizedDescription)")
                return completion(.failure(.fetchError))
            }
            
            guard let records = records else { return completion(.success(nil)) }
            
            guard let conversationRecord = records.first,
                  let conversation = Conversation(conversationRecord: conversationRecord) else { return completion(.failure(.fetchError)) }
            
            return completion(.success(conversation))
        }
    }
    
    //  MARK: - MESSAGE FUNCTIONS
    static func sendNewMessageWith(conversationRef: CKRecord.Reference, text: String, completion: @escaping(Result<Message, CKError>) -> Void) {
        guard let selfSender = CKController.selfSender else { return completion(.failure(.createError)) }
        
        let senderRef = CKRecord.Reference(recordID: selfSender.ckRecordID, action: .none)
        
        let message = Message(senderRef: senderRef, messageText: text)
        
        //  save message to existing conversation
        let messageRecord = CKRecord(message: message, conversationRef: conversationRef)
        
        save(messageRecord: messageRecord) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let message):
                    print("successully saved message with id: \(message.ckRecordID.recordName)")
                    completion(.success(message))
                    
                case .failure(let error):
                    print("***Error*** in Function: \(#function)\n\nError: \(error)\n\nDescription: \(error.localizedDescription)")
                    completion(.failure(.createError))
                }
            }
        }
    }
    
    static func save(messageRecord: CKRecord, completion: @escaping(Result<Message, CKError>) -> Void ) {
        publicDB.save(messageRecord) { record, error in
            if let error = error {
                print("***Error*** in Function: \(#function)\n\nError: \(error)\n\nDescription: \(error.localizedDescription)")
                return completion(.failure(.createError))
            }
            
            guard let record = record,
                  let message = Message(messageRecord: record) else { return completion(.failure(.createError)) }
            
            completion(.success(message))
        }
    }
    
    static func fetchMessageWith(messageID: String, completion: @escaping(Result<Message, CKError>) -> Void) {
        
    }
}   //  End of Struct
