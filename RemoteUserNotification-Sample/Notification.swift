//
//  NotificationData.swift
//  CurDr_TW
//
//  Created by 林翌埕 on 2019/3/5.
//  Copyright © 2019 Benson Lin. All rights reserved.
//

import Foundation

struct NotificationData: Codable {
    let aps: Aps?
    let acme: Acme?

    enum CodingKeys: String, CodingKey {
        case aps = "aps"
        case acme = "acme"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        aps = try values.decodeIfPresent(Aps.self, forKey: .aps)
        acme = try values.decodeIfPresent(Acme.self, forKey: .acme)
    }
}

struct Aps: Codable {
    
    let contentAvailable: Int?
    let alert: String?
    let sound: String?
    let badge: Int?
    let notificationType: NotificationType?
    
    enum NotificationType: String, Codable {
        case notify
        case ring
        case stopRing
    }
    
    enum CodingKeys: String, CodingKey {
        
        case contentAvailable = "content-available"
        case alert
        case sound
        case badge
        case notificationType
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        contentAvailable = try values.decodeIfPresent(Int.self, forKey: .contentAvailable)
        alert = try values.decodeIfPresent(String.self, forKey: .alert)
        sound = try values.decodeIfPresent(String.self, forKey: .sound)
        badge = try values.decodeIfPresent(Int.self, forKey: .badge)
        notificationType = try values.decodeIfPresent(NotificationType.self, forKey: .notificationType)
    }
}

struct Acme : Codable {
    let roomNumber : String?
    let queueID : String?
    let doctorName : String?
    
    enum CodingKeys: String, CodingKey {
        case roomNumber
        case queueID
        case doctorName
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        roomNumber = try values.decodeIfPresent(String.self, forKey: .roomNumber)
        queueID = try values.decodeIfPresent(String.self, forKey: .queueID)
        doctorName = try values.decodeIfPresent(String.self, forKey: .doctorName)
    }
}
