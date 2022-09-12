//
//  NotidicationVAlue.swift
//  DynamicIslandAnimation
//
//  Created by 山本響 on 2022/09/12.
//

import SwiftUI
import UserNotifications

struct NotificationValue: Identifiable {
    var id: String = UUID().uuidString
    var content: UNNotificationContent
    var dateCreated: Date = Date()
    var showNotification: Bool = false
}
