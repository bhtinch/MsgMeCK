//
//  FindUserTableViewController.swift
//  MsgMeCK
//
//  Created by Benjamin Tincher on 6/23/21.
//

import UIKit
import CloudKit

class FindUserTableViewController: UITableViewController {
    //  MARK: - OUTLETS
    //Need SearchBar
    
    //  MARK: - PROPERTIES
    var senders: [Sender] = []
    
    //  MARK: - LIFECYCLES
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchSenderRefs()
    }
    
    //  MARK: - METHODS
    func fetchSenderRefs() {
        CKController.fetchAllSenders { result in
            switch result {
            case .success(let senderRefs):
                CKController.senderRefs = senderRefs
                self.fetchSenders()
            case .failure(let error):
                print("***Error*** in Function: \(#function)\n\nError: \(error)\n\nDescription: \(error.localizedDescription)")
            }
        }
    }
    
    func fetchSenders() {
        
        let senderIDs = CKController.senderRefs.compactMap { $0.recordID }

        CKController.fetchSendersByRecordIdOrAppleId(appleID: nil, recordIDs: senderIDs) { senders in
            if let senders = senders {
                self.senders = senders
                self.tableView.reloadData()
            } else {
                print("error fetching all sender records")
            }
        }
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return senders.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let sender = senders[indexPath.row]
        
        cell.textLabel?.text = sender.displayName
        
        return cell
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toNewConvoVC" {
            guard let indexPath = tableView.indexPathForSelectedRow,
                  let destination = segue.destination as? ConversationViewController else { return }
            
            let otherSender = senders[indexPath.row]
            destination.otherSender = otherSender
            
            destination.otherSenderRef = CKRecord.Reference(recordID: otherSender.ckRecordID, action: .none)
            destination.conversation = nil
            
        }
    }
}
