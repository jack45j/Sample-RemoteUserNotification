//
//  UNUserNotificationManager.swift
//  CurDr_TW_Doctor
//
//  Created by 林翌埕 on 2018/10/1.
//  Copyright © 2018 Benson Lin. All rights reserved.
//

import UserNotifications
import UIKit

protocol UserNotificationManagerDelegate: class {
    func getDeviceToken(token pushNotificationTokenString: String)
}

final class UserNotificationManager: NSObject {
    
    /// set to true/false to enable/disable UNM log.
    internal lazy var isDebugEnable = true
    
    /// UNM singleton.
    internal static let shared = UserNotificationManager()
    
    /// UNM protocol.
    weak var delegate: UserNotificationManagerDelegate?
    
    /// UNM denied alertController configuration.
    var deniedAlertTitle: String? = "Notification Permission Denied."
    var deniedAlertMessage: String? = "Please accept notification permission for better user experience."
    var deniedAlertStyle: UIAlertController.Style = .alert
    var deniedAlertCancelButtonString: String? = "Cancel"
    var deniedAlertSettingsButtonString: String? = "Settings"
    
    internal func requestNotification(options: UNAuthorizationOptions = [.alert, .sound, .badge]) {
        UNUserNotificationCenter.current().requestAuthorization(options: options) { (permissionGranted, error) in
            
            if !permissionGranted {
                self.printUserNotificationLog("Permission denied.")
                let requestNotificationPermissionAlertController = UIAlertController(
                        title: self.deniedAlertTitle!,
                        message: self.deniedAlertMessage!,
                        preferredStyle: self.deniedAlertStyle)
                
                let cancelAlertAction = UIAlertAction(title: self.deniedAlertCancelButtonString, style: .cancel, handler: nil)
                let settingAlertAction = UIAlertAction(title: self.deniedAlertSettingsButtonString, style: .destructive, handler: { (_) in
                    if !UIApplication.shared.isRegisteredForRemoteNotifications {
                        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
                    }
                })
                requestNotificationPermissionAlertController.addAction(settingAlertAction)
                requestNotificationPermissionAlertController.addAction(cancelAlertAction)
                UIApplication.shared.keyWindow?.rootViewController?.present(requestNotificationPermissionAlertController, animated: true, completion: nil)
            } else {
                self.printUserNotificationLog("Successfully granted remote notification permission.")
            }
        }
        UIApplication.shared.registerForRemoteNotifications()
    }
    
    
    fileprivate func didReceiveRemoteNotification(userInfo: [AnyHashable: Any]) {
        self.printUserNotificationLog("Received remote user notification. \(userInfo)")
        
        
        guard
            let payloadDictionary = userInfo as? [String: Any],
            let dictionaryData = try? JSONSerialization.data(withJSONObject: payloadDictionary, options: []),
            let UNdata = try? JSONDecoder().decode(NotificationData.self, from: dictionaryData)
            else { return }
        
        switch UNdata.aps!.notificationType! {
        case .notify:
            /// set badgeNumber
            if let badgeNumber = UNdata.aps?.badge {
                UserNotificationManager.shared.setBadgeNumber(to: badgeNumber)
            }
        case .ring:
            print("ring")
        case .stopRing:
            print("stop ring")
        }
    }
    
    
    fileprivate func didRegisterRemoteNotification(token deviceToken: Data) {
        printUserNotificationLog("Device Token: \(deviceToken.convertTokenDataToString)")
        delegate?.getDeviceToken(token: deviceToken.convertTokenDataToString)
    }
    
    
    fileprivate func didFailRegisterRemoteNotification(error: Error) {
        printUserNotificationLog("Fail to register remote Notification with error: \(error.localizedDescription)")
    }
    
    
    private func setBadgeNumber(to count: Int) {
        UIApplication.shared.applicationIconBadgeNumber = count
        printUserNotificationLog("Set application icon badge number to \(count)")
    }
}


/// Router for UserNotificationLog
extension UserNotificationManager {
    fileprivate func printUserNotificationLog(_ message: String) {
        if isDebugEnable {
            UserNotificationLog(message)
        }
    }
}


private struct UserNotificationLog {
    @discardableResult
    init(_ message: String) {
        if TargetManager.shared.enableDebugMode {
            NSLog("[UserNotification] \(message)")
        }
    }
}


/// MARK: - AppDelegate
///
extension AppDelegate {
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        UserNotificationManager.shared.didRegisterRemoteNotification(token: deviceToken)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        UserNotificationManager.shared.didFailRegisterRemoteNotification(error: error)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        UserNotificationManager.shared.didReceiveRemoteNotification(userInfo: userInfo)
    }
}


extension UserNotificationManager: UNUserNotificationCenterDelegate {
    
    /// let notification display while app is in foreground.
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        completionHandler([.alert, .sound])
    }
}
