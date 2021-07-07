//
//  AppDelegate.swift
//  MsgMeCK
//
//  Created by Benjamin Tincher on 6/4/21.
//

import UIKit
import CloudKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (success, error) in
            
            if let error = error {
                print("There was an error in \(#function) ; \(error)  ; \(error.localizedDescription)")
                return
            }
            success ? print("Successfully authorized to send push notfiication") : print("DENIED, Can't send this person notificiation")
            DispatchQueue.main.async {
                application.registerForRemoteNotifications()
            }
        }
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    //  MARK: - NOTIFICAITONS
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("\n***\(#function) fired this statement.***\nLooks like the application successfully registered for notificaitons.\n")
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("\n***\(#function) fired this statement.***\nLooks like the application failed to register for notificaitons.\nError: \(error.localizedDescription)")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        guard let dict = userInfo as? [String : [String: Any]],
              let apsDict = dict["aps"],
              let ckDict = dict["ck"],
              let queryDict = ckDict["qry"] as? [String : Any],
              let subscriptionID = queryDict["sid"] as? String else { return }
        
        print("notification arrived from subscriptionID: \(subscriptionID)\n")
        print("apsDict is below.\n\(apsDict)")
        print("ckDict is below.\n\(ckDict)")
        
        if subscriptionID == "newConversations" {
            ObserveObjects.shared.newConversation.toggle()
        } else {
            ObserveObjects.shared.newMessage.toggle()
        }
        completionHandler(.newData)
    }
    
}

