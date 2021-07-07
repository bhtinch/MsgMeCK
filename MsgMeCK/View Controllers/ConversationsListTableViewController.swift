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
    var otherSenders: [Sender]?
    
    //  MARK: - LIFECYCLES
    override func viewDidLoad() {
        super.viewDidLoad()
        addBarButton.isEnabled = false
        configureRefreshControl()
        subscribeToNewConversations()
        setObserver()
        
        fetchAppleID()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        tableView.reloadData()
    }
    
    //  MARK: - METHODS
    func configureRefreshControl () {
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: #selector(handleRefreshControl), for: .valueChanged)
        
    }
    
    @objc func handleRefreshControl() {
        self.fetchConversations()
        
        // Dismiss the refresh control.
        DispatchQueue.main.async {
            self.refreshControl?.endRefreshing()
        }
    }
    
    func subscribeToNewConversations() {
        CKController.subscribeToNewConvesations()
    }
    
    func setObserver() {
        print("observer set")
        
        CKController.setNewConversationObserver(observeObject: ObserveObjects.shared) { _ in
            self.handleRefreshControl()
        }
    }
    
    func fetchAppleID() {
        // fetch icloud appleID
        CKController.fetchCurrentAppleUser { record in
            if let appleUserRecord = record {
                self.fetchSenderWith(appleUserRecordID: appleUserRecord.recordID)
            } else {
                self.addBarButton.isEnabled = false
                Alerts.presentAlertWith(title: "Whoops!", message: "Please sign into iCloud in your device settings to use this app.", sender: self)
            }
        }
    }
    
    func fetchSenderWith(appleUserRecordID: CKRecord.ID) {
        //  fetch Sender record
        CKController.fetchSendersByRecordIdOrAppleId(appleID: appleUserRecordID, recordIDs: nil) { senders in
            
            if let senders = senders {
                //  sender record exists and fetched
                guard let selfSender = senders.first else { return }
                print("sender successfully fetched with id: \(selfSender)")
                CKController.selfSender = selfSender
                
                self.addBarButton.isEnabled = true
                self.fetchConversations()
                
            } else {
                //  sender record does not exist; need to create one
                print("\nSender does not exist yet for this apple user.\n")
                self.createNewSenderWith(appleID: appleUserRecordID)
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
            if let selfSender = sender {
                CKController.selfSender = selfSender
                print("sender successfully created with id: \(selfSender.ckRecordID.recordName)")
                self.addBarButton.isEnabled = true
            } else {
                Alerts.presentAlertWith(title: "Whoops!", message: "There was an error creating your account.  Please close the app and try again.", sender: self)
            }
        }
    }
    
    func fetchConversations() {
        CKController.fetchAllConversations() { result in
            switch result {
            case .success(let convos):
                CKController.conversations = convos
                self.fetchOtherSenders()
            case .failure(let error):
                print("***Error*** in Function: \(#function)\n\nError: \(error)\n\nDescription: \(error.localizedDescription)")
            }
        }
    }
    
    func fetchOtherSenders() {
        let recordIDs: [CKRecord.ID] = CKController.conversations.compactMap {
            var recordID = $0.senderARef.recordID
            
            if recordID == CKController.selfSenderRef?.recordID {
                recordID = $0.senderBRef.recordID
            }
            
            return recordID
        }
        
        CKController.fetchSendersByRecordIdOrAppleId(appleID: nil, recordIDs: recordIDs) { senders in
            guard let senders = senders,
                  senders.count == CKController.conversations.count else { return }
            
            self.otherSenders = senders
            self.tableView.reloadData()
        }
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CKController.conversations.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        let otherSender = otherSenders?[indexPath.row]
        
        cell.textLabel?.text = otherSender?.displayName ?? "Unknown Sender"

        return cell
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toConversationVC" {
            guard let indexPath = tableView.indexPathForSelectedRow,
                  let destination = segue.destination as? ConversationViewController,
                  let otherSender = otherSenders?[indexPath.row] else { return }
            
            let conversation = CKController.conversations[indexPath.row]
            destination.conversation = conversation
            destination.otherSender = otherSender
            destination.otherSenderRef = CKRecord.Reference(recordID: otherSender.ckRecordID, action: .none)
        }
    }
}   //  End of Class
