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
    
    static var messages: [Message] = []
    static var conversations: [Conversation] = []
    static var senderRefs: [CKRecord.Reference] = []
    static var selfSender: Sender? {
        didSet {
            if let selfSender = selfSender {
                selfSenderRef = CKRecord.Reference(recordID: selfSender.ckRecordID, action: .none)
            }
        }
    }
    static var selfSenderRef: CKRecord.Reference?
    
    //  MARK: - USER FUNCTIONS
    static func fetchCurrentAppleUser(completion: @escaping (CKRecord?) -> Void) {
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
    
    static func fetchSendersByRecordIdOrAppleId(appleID: CKRecord.ID?, recordIDs: [CKRecord.ID]?, completion: @escaping([Sender]?) -> Void) {
        
        if let appleID = appleID {
            let predicate = NSPredicate(format: "%K == %@", SenderStrings.appleID, appleID)
            
            let query = CKQuery(recordType: SenderStrings.recordType, predicate: predicate)
            
            publicDB.perform(query, inZoneWith: nil) { (records, error) in
                DispatchQueue.main.async {
                    if let error = error {
                        print("\n***Error*** in \(#function)\n\nSender(s) could not be found\n")
                        return completion(nil)
                    }
                    
                    guard let records = records,
                          let senderRecord = records.first,
                          let sender = Sender(senderRecord: senderRecord) else { return completion(nil) }
                    
                    return completion([sender])
                }
            }
            
        } else if let recordIDs = recordIDs {
            let fetchOp = CKFetchRecordsOperation(recordIDs: recordIDs)
            fetchOp.qualityOfService = .userInitiated
            
            fetchOp.fetchRecordsCompletionBlock = { (records, error) in
                DispatchQueue.main.async {
                    if let error = error {
                        print("***Error*** in Function: \(#function)\n\nError: \(error)\n\nDescription: \(error.localizedDescription)")
                        return completion(nil)
                    }
                    
                    if let records = records {
                        let senders = records.compactMap { Sender(senderRecord: $0.value) }
                        completion(senders)
                    }
                }
            }
        }
    }
    
    static func saveNewSenderWith(appleID: CKRecord.ID, displayName: String, completion: @escaping(Sender?) -> Void) {
        let sender = Sender(displayName: displayName, appleID: appleID)
        
        let newSenderRecord = CKRecord(sender: sender)
        
        publicDB.save(newSenderRecord) { record, error in
            DispatchQueue.main.async {
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
    }
    
    static func fetchAllSenders(completion: @escaping(Result<[CKRecord.Reference], CKError>) -> Void ) {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: SenderStrings.recordType, predicate: predicate)
        guard let selfSender = selfSender else { return completion(.failure(CKError.fetchError)) }
        
        publicDB.perform(query, inZoneWith: nil) { (records, error) in
            DispatchQueue.main.async {
                if let error = error {
                    print("***Error*** in Function: \(#function)\n\nError: \(error)\n\nDescription: \(error.localizedDescription)")
                    return completion(.failure(.fetchError))
                }
                
                guard var records = records else { return completion(.success([])) }
                records.sort { ($0[SenderStrings.displayName] as! String) < ($1[SenderStrings.displayName] as! String) }
                                
                var senderRefs = records.compactMap { CKRecord.Reference(recordID: $0.recordID, action: .none) }
                
                let selfSenderRef = CKRecord.Reference(recordID: selfSender.ckRecordID, action: .none)
                
                if let selfSenderIndex = senderRefs.firstIndex(of: selfSenderRef) {
                    senderRefs.remove(at: selfSenderIndex)
                }
                
                completion(.success(senderRefs))
            }
        }
    }
    
    
    //  MARK: - CONVERSATION FUNCTIONS
    static func createNewConversationWith(otherSenderRef: CKRecord.Reference, completion: @escaping(Conversation?) -> Void ) {
        guard let selfSenderRef = selfSenderRef else { return completion(nil) }
        let conversation = Conversation(senderARef: selfSenderRef, senderBRef: otherSenderRef)
        
        let conversationRecord = CKRecord(conversation: conversation)
        
        publicDB.save(conversationRecord) { record, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("***Error*** in Function: \(#function)\n\nError: \(error)\n\nDescription: \(error.localizedDescription)")
                    return completion(nil)
                }
                
                guard let record = record else { return completion(nil) }
                
                let conversation = Conversation(conversationRecord: record)
                
                completion(conversation)
            }
        }
    }
    
    static func fetchAllConversations(completion: @escaping(Result<[Conversation], CKError>) -> Void ) {
        guard let selfSender = selfSender else { return completion(.failure(CKError.fetchError)) }
        let selfSenderRef = CKRecord.Reference(recordID: selfSender.ckRecordID, action: .none)
        
        let predA = NSPredicate(format: "%K == %@", ConversationStrings.senderARef, selfSenderRef)
        let predB = NSPredicate(format: "%K == %@", ConversationStrings.senderBRef, selfSenderRef)

        let compoundPred = NSCompoundPredicate(orPredicateWithSubpredicates: [predA, predB])
        
        let query = CKQuery(recordType: ConversationStrings.recordType, predicate: compoundPred)
        
        publicDB.perform(query, inZoneWith: nil) { (records, error) in
            DispatchQueue.main.async {
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
    }
    
    static func fetchConversationWith(selfSenderRef: CKRecord.Reference, otherSenderRef: CKRecord.Reference, completion: @escaping(Result<Conversation?, CKError>) -> Void ) {
        
        let predA = NSPredicate(format: "%K == %@ AND %K == %@", ConversationStrings.senderARef, selfSenderRef, ConversationStrings.senderBRef, otherSenderRef)
        let predB = NSPredicate(format: "%K == %@ AND %K == %@", ConversationStrings.senderARef, otherSenderRef, ConversationStrings.senderBRef, selfSenderRef)

        let compoundPred = NSCompoundPredicate(orPredicateWithSubpredicates: [predA, predB])
        
        let query = CKQuery(recordType: ConversationStrings.recordType, predicate: compoundPred)
        
        publicDB.perform(query, inZoneWith: nil) { (records, error) in
            DispatchQueue.main.async {
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
    }
    
    //  MARK: - MESSAGE FUNCTIONS
    static func sendNewMessageTo(conversation: Conversation, text: String, completion: @escaping(Message?) -> Void) {
        guard let selfSenderRef = CKController.selfSenderRef else { return completion(nil) }
        
        let conversationRef = CKRecord.Reference(recordID: conversation.ckRecordID, action: .none)
        
        let message = Message(messageText: text, senderObjectRef: selfSenderRef)
        
        //  save message to existing conversation
        let messageRecord = CKRecord(message: message, conversationRef: conversationRef)
        
        publicDB.save(messageRecord) { record, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("***Error*** in Function: \(#function)\n\nError: \(error)\n\nDescription: \(error.localizedDescription)")
                    return completion(nil)
                }
                
                guard let record = record,
                      let message = Message(messageRecord: record) else { return completion(nil) }
                
                completion(message)
            }
        }
    }
    
    static func fetchMessagesFor(conversation: Conversation, completion: @escaping([Message]) -> Void ) {
        let conversationRef = CKRecord.Reference(recordID: conversation.ckRecordID, action: .none)
        
        let predicate = NSPredicate(format: "%K == %@", MessageStrings.conversationRef, conversationRef)
        
        let query = CKQuery(recordType: MessageStrings.recordType, predicate: predicate)
        
        publicDB.perform(query, inZoneWith: nil) { (records, error) in
            DispatchQueue.main.async {
                if let error = error {
                    print("***Error*** in Function: \(#function)\n\nError: \(error)\n\nDescription: \(error.localizedDescription)")
                    return completion([])
                }
                
                guard var records = records else { return completion([]) }
                
                records.sort { $0.modificationDate! < $1.modificationDate! }
                
                let messages = records.compactMap { Message(messageRecord: $0) }
                return completion(messages)
            }
        }
    }
    
}   //  End of Struct
