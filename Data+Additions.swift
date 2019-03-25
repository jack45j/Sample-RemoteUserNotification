//
//  DataExtension.swift
//  CurDr_TW_Doctor
//
//  Created by 林翌埕 on 2018/10/4.
//  Copyright © 2018 Benson Lin. All rights reserved.
//

import Foundation

extension Data {
    /// Use to convert PushKit token and UserNotification push token to String
    var convertTokenDataToString: String {
        let tokenParts = self.map { data -> String in
            return String(format: "%02.2hhx", data)
        }
        return tokenParts.joined()
    }
}
