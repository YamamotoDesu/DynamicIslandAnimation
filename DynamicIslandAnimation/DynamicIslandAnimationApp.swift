//
//  DynamicIslandAnimationApp.swift
//  DynamicIslandAnimation
//
//  Created by 山本響 on 2022/09/12.
//

import SwiftUI
import UserNotifications

@main
struct DynamicIslandAnimationApp: App {
    // MARK: Linking App Delegate
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @State var notifications: [NotificationValue] = []
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .overlay(alignment: .top) {
                    GeometryReader { proxy in
                        let size = proxy.size
                        
                        ForEach(notifications) { notification in
                            NotificationPreview(size: size, value: notification, notifications: $notifications)
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                        }
                        
                    }
                    .ignoresSafeArea()
                }
                .onReceive(NotificationCenter.default.publisher(for: Notification.Name("NOTIFY"))) { output in
                    if let content = output.userInfo?["content"] as? UNNotificationContent {
                        // MARK: Creating New Notification
                        let newNotofication = NotificationValue(content: content)
                        notifications.append(newNotofication)
                    }
                    
                }
        }
    }
}

struct NotificationPreview: View {
    var size: CGSize
    var value: NotificationValue
    @Binding var notifications: [NotificationValue]
    var body: some View {
        HStack {
            // MARK: UI
            if let image = UIImage(named: "AppIcon60x60") {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(width: value.showNotification ? size.width - 22 : 126, height: value.showNotification ? 100 : 37.33)
        .background {
            RoundedRectangle(cornerRadius: value.showNotification ? 50: 63, style: .continuous)
                .fill(.black)
        }
        .offset(y: 11)
        .animation(.interactiveSpring(response: 0.6, dampingFraction: 0.7, blendDuration: 0.7), value: value.showNotification)
        .onChange(of: value.showNotification, perform: { newValue in
            if newValue && notifications.indices.contains(index) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    notifications[index].showNotification = false
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                    notifications.remove(at: index)
                }
            }
            
        })
        .onAppear {
            // MARK: Animating When A New Notification is  Added
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                notifications[index].showNotification = true
            }
        }
    }
    
    // MARK: Index
    var index: Int {
        return notifications.firstIndex { CValue in
            CValue.id == value.id
        } ?? 0
    }
}

// MARK: App Delegate to Listen for App Notifications
class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        return true
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        if UIApplication.shared.haveDynamicIsland {
            // MARK: DO Animation
            // MARK: Observing Notification
            NotificationCenter.default.post(name: NSNotification.Name("NOTIFY"), object: nil, userInfo: ["content" : notification.request.content])
            return [.sound]
        } else {
            // MARK: NORMAL Notification
            return [.sound, .banner]
        }
    }
}

extension UIApplication {
    var haveDynamicIsland: Bool {
        return deviceName == "iPhone 14 Pro" || deviceName == "iPhone 14 Pro Max"
    }
    
    var deviceName: String {
        return UIDevice.current.name
    }
}
