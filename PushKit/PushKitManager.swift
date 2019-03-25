//
//  PushKitManager.swift
//  CurDr_TW_Doctor
//
//  Created by 林翌埕 on 2018/10/4.
//  Copyright © 2018 Benson Lin. All rights reserved.
//

import Foundation
import UIKit
import PushKit
import UserNotifications

protocol PushKitManagerDelegate: class {
    func getPushToken(pushTokenString: String)
}

class PushKitManager: NSObject {
    
    internal lazy var isDebugEnable = false
    
    internal static let shared = PushKitManager()
    
    weak var delegate: PushKitManagerDelegate?
    
    internal func registerPushKitVoipService() {
        let voipRegistry = PKPushRegistry(queue: DispatchQueue.main)
        voipRegistry.delegate = UIApplication.shared.delegate as! AppDelegate // swiftlint:disable:this force_cast
        voipRegistry.desiredPushTypes = [.voIP]
    }
    
    
    internal func didUpdatePushCredential(credential pushCredentials: PKPushCredentials, type: PKPushType) {
        if type == .voIP && pushCredentials.token.count > 0 {
            let credentialsDataString = pushCredentials.token.convertTokenDataToString
            PushKitLog("Push Token: \(credentialsDataString)")
            UserDefaults.standard.set(credentialsDataString, forKey: "voipToken")
            delegate?.getPushToken(pushTokenString: credentialsDataString)
        }
    }
    
    
    internal func didReceiveIncomingPushWith(payload: PKPushPayload, type: PKPushType) {
        PushKitLog("Received incoming push.")
        
        var nameKeyString: String?
        
        switch TargetManager.shared.currentTarget! {
        default:
            nameKeyString = "doctorName"
        }
        
        if type == .voIP {
            PushKitLog("Push payload(voIP): \(payload.dictionaryPayload)")
            guard
                let payloadDictionary = payload.dictionaryPayload[AnyHashable("acme")] as? NSDictionary,
                let doctorName = payloadDictionary[nameKeyString!] as? String,
                let queueID = payloadDictionary["queueID"]  as? String,
                let roomNumber = payloadDictionary["roomNumber"] as? String
            else { return }
            
            if #available(iOS 10.0, *) {
                let backgroundTaskIdentifier = UIApplication.shared.beginBackgroundTask(expirationHandler: nil)
                DispatchQueue.main.asyncAfter(wallDeadline: DispatchWallTime.now() + 1.5) {
                    AppDelegate.shared.displayIncomingCall(uuid: UUID(), handle: roomNumber, callerName: doctorName, queueID: queueID, hasVideo: false, completion: { (error) in
                        print(error?.localizedDescription ?? "Unknown error")
                        UIApplication.shared.endBackgroundTask(backgroundTaskIdentifier)
                    })
                }
            }
        }
    }
}


/// MARK: - Router for PushKitLog
///
extension PushKitManager {
    fileprivate func printUserNotificationLog(_ message: String) {
        if isDebugEnable {
            PushKitLog(message)
        }
    }
}


private struct PushKitLog {
    @discardableResult
    init(_ message: String) {
        if TargetManager.shared.enableDebugMode {
            NSLog("[PushKit] \(message)")
        }
    }
}


/// MARK: - PKPushRegistryDelegate
///
extension AppDelegate: PKPushRegistryDelegate {
    func pushRegistry(_ registry: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType) {
        PushKitManager.shared.didUpdatePushCredential(credential: pushCredentials, type: type)
    }
    
    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType, completion: @escaping () -> Void) {
        PushKitManager.shared.didReceiveIncomingPushWith(payload: payload, type: type)
        DispatchQueue.main.async {
            completion()
        }
    }
}
