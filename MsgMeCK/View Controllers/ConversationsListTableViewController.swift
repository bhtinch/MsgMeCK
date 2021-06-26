//
//  ConversationsListTableViewController.swift
//  MsgMeCK
//
//  Created by Benjamin Tincher on 6/16/21.
//

import UIKit
import CloudKit
import MessageKit

class ConversationsListTableViewController: UITableViewController {
    //  MARK: - OUTLETS
    @IBOutlet weak var addBarButton: UIBarButtonItem!
    
    //  MARK: - PROPERTIES
    var conversations: [Conversation] = []

    //  MARK: - LIFECYCLES
    override func viewDidLoad() {
        super.viewDidLoad()
        addBarButton.isEnabled = false
        fetchAppleID()
    }
    
    //  MARK: - ACTIONS
    
    //  MARK: - METHODS
    func fetchAppleID() {
        // fetch icloud id
        CKController.fetchCurrentUser { record in
            DispatchQueue.main.async {
                if let record = record {
                    self.fetchSenderWith(userRecordID: record.recordID)
                } else {
                    self.addBarButton.isEnabled = false
                    Alerts.presentAlertWith(title: "Whoops!", message: "Please sign into iCloud in your device settings to use this app.", sender: self)
                }
            }
        }
    }
    
    func fetchSenderWith(userRecordID: CKRecord.ID) {
        let userRef = CKRecord.Reference(recordID: userRecordID, action: .none)
        
        //  fetch Sender record
        CKController.fetchSenderByUserRefOrAppleID(userRef: userRef) { sender in
            DispatchQueue.main.async {
                
                if let sender = sender {
                    //  sender record exists and fetched
                    print("sender successfully fetched with id: \(sender.ckRecordID.recordName)")
                    CKController.selfSender = sender
                    let senderRef = CKRecord.Reference(recordID: sender.ckRecordID, action: .none)
                    self.addBarButton.isEnabled = true
                    self.fetchConversationsWith(senderRef: senderRef)
                    
                } else {
                    //  sender record does not exist; need to create one
                    self.createNewSenderWith(appleID: userRecordID)
                }
            }
        }
    }
    
    func createNewSenderWith(appleID: CKRecord.ID) {
        let alert = Alerts.createAlertWith(title: "Welcome to MsgMeCK!", message: "Please create your profile below.  All fields are required.", sender: self, textFieldPlaceHolderText: ["Enter your display name..."])
        
        alert.actions.first?.isEnabled = false
        
        let createAction = UIAlertAction(title: "Create!", style: .default) { _ in
            guard let displayName = alert.textFields?.first?.text, !displayName.isEmpty else {
                Alerts.presentActionSheetWith(title: "Please complete all fields.", message: nil, sender: self) {
                    self.createNewSenderWith(appleID: appleID)
                }
                return
            }
            
            self.saveNewSenderWith(appleID: appleID, displayName: displayName)
            alert.dismiss(animated: true, completion: nil)
        }
        
        alert.addAction(createAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    func saveNewSenderWith(appleID: CKRecord.ID, displayName: String) {
        
        CKController.saveNewSenderWith(appleID: appleID, displayName: displayName) { sender in
            DispatchQueue.main.async {
                if let selfSender = sender {
                    CKController.selfSender = selfSender
                    print("sender successfully created with id: \(selfSender.ckRecordID.recordName)")
                    self.addBarButton.isEnabled = true
                } else {
                    Alerts.presentAlertWith(title: "Whoops!", message: "There was an error creating your account.  Please close the app and try again.", sender: self)
                }
            }
        }
    }
    
    func fetchConversationsWith(senderRef: CKRecord.Reference) {
        CKController.fetchAllConversationsWith(senderRef: senderRef) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let convos):
                    self.conversations = convos
                    self.tableView.reloadData()
                case .failure(let error):
                    print("***Error*** in Function: \(#function)\n\nError: \(error)\n\nDescription: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CKController.conversations.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        let conversation = CKController.conversations[indexPath.row]
        
        cell.textLabel?.text = conversation.otherSender.displayName

        return cell
    }

//    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == .delete {
//            // Delete the row from the data source
//            tableView.deleteRows(at: [indexPath], with: .fade)
//        }
//    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toConversationVC" {
            guard let indexPath = tableView.indexPathForSelectedRow,
                  let destination = segue.destination as? ConversationViewController else { return }
            
            let conversationID = conversations[indexPath.row].ckRecordID
            let conversationRef = CKRecord.Reference(recordID: conversationID, action: .none)
            destination.conversationRef = conversationRef
            destination.otherSender = conversations[indexPath.row].otherSender
        }
    }
}   //  End of Class
