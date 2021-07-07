//
//  Alerts.swift
//  MsgMeCK
//
//  Created by Benjamin Tincher on 6/24/21.
//

import Foundation
import UIKit

class Alerts: UIViewController {
    
    static func presentAlertWith(title: String, message: String?, sender: UIViewController) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            alert.dismiss(animated: true, completion: nil)
        }))
        
        sender.present(alert, animated: true, completion: nil)
    }
    
    static func createAlertWith(title: String, message: String?, sender: UIViewController, textFieldPlaceHolderText: [String]?) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
            alert.dismiss(animated: true, completion: nil)
        }))
        
        if let textFieldCount = textFieldPlaceHolderText?.count {
            for i in 0..<textFieldCount {
                alert.addTextField { tf in
                    tf.placeholder = textFieldPlaceHolderText?[i] ?? nil
                }
            }
        }
        
        return alert
    }
    
    static func presentActionSheetWith(title: String, message: String?, sender: UIViewController, dismissCompletion: (() -> Void)?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            alert.dismiss(animated: true, completion: dismissCompletion)
        }))
        
        sender.present(alert, animated: true, completion: nil)
    }
}
