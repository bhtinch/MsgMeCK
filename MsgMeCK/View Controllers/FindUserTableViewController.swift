//
//  FindUserTableViewController.swift
//  MsgMeCK
//
//  Created by Benjamin Tincher on 6/23/21.
//

import UIKit

class FindUserTableViewController: UITableViewController {
    //  MARK: - OUTLETS
    //Need SearchBar
    
    //  MARK: - LIFECYCLES
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchSenders()
    }
    
    //  MARK: - METHODS
    func fetchSenders() {
        CKController.fetchAllSenders { result in
            switch result {
            case .success(let senders):
                CKController.senders = senders
                self.tableView.reloadData()
            case .failure(let error):
                print("***Error*** in Function: \(#function)\n\nError: \(error)\n\nDescription: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CKController.senders.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let sender = CKController.senders[indexPath.row]
        
        cell.textLabel?.text = sender.displayName
        
        return cell
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toNewConvoVC" {
            guard let indexPath = tableView.indexPathForSelectedRow,
                  let destination = segue.destination as? ConversationViewController else { return }
            
            destination.otherSender = CKController.senders[indexPath.row]
            destination.conversation = nil
        }
    }
}
