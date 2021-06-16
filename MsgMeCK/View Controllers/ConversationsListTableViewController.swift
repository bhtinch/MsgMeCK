//
//  ConversationsListTableViewController.swift
//  MsgMeCK
//
//  Created by Benjamin Tincher on 6/16/21.
//

import UIKit

class ConversationsListTableViewController: UITableViewController {
    
    //  MARK: - PROPERTIES
    var conversations: [Conversation] = []

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)


        return cell
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toConversationVC" {
            guard let indexPath = tableView.indexPathForSelectedRow,
                  let destination = segue.destination as? ConversationViewController else { return }
            
            let conversationID = conversations[indexPath.row].conversationID
            destination.conversationID = conversationID
        }
    }
}   //  End of Class
