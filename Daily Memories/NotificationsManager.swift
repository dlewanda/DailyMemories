//
//  NotificationManager.swift
//  Daily Memories
//
//  Created by David Lewanda on 3/28/20.
//  Copyright © 2020 LewandaCode. All rights reserved.
//

import UserNotifications
import Combine

struct Notification {
    var id: String
    var title: String
    var body: String
}

@objc class NotificationsManager: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationsManager()

    @Published var notificationsAuthorized: Bool = false
    @Published var schedulingNotificationEnabled: Bool = false {
        didSet {
            if schedulingNotificationEnabled {
                if notificationTime == Date.distantFuture {
                    // if enabled but no date set, schedule one for right now
                    scheduleNotification(at: Date())
                } else {
                    scheduleNotification(at: notificationTime)
                }
            } else {
                cancelNotification()
            }
        }
    }

    @Published var notificationTime: Date = Date.distantFuture {
        didSet {
            if schedulingNotificationEnabled {
                scheduleNotification(at: notificationTime)
            } else {
                // should not be able to get here
            }
        }
    }

    private let notificationCategoryIdentifier = "dailyMemoriesNotification"
    private var notification = Notification(id: UUID().uuidString,
                                            title: "Your Daily Memory",
                                            body: "Time for your daily trip down memory lane!")
    private var requestCancellable: Cancellable?
    private var imageCancellable: Cancellable?

    private override init() {
        super.init()
        
        let currentUserNotificationsCenter = UNUserNotificationCenter.current()

        currentUserNotificationsCenter.delegate = self

        let dailyMemoriesNotificationCategory = UNNotificationCategory(identifier: notificationCategoryIdentifier,
                                                                       actions: [],
                                                                       intentIdentifiers: [],
                                                                       options: [])

        currentUserNotificationsCenter.setNotificationCategories([dailyMemoriesNotificationCategory])

        currentUserNotificationsCenter.getPendingNotificationRequests { requests in
            for request in requests {
                guard let calendarTrigger = request.trigger as? UNCalendarNotificationTrigger,
                    let triggerTime = Calendar.current.date(from: calendarTrigger.dateComponents) else {
                        break
                }

                DispatchQueue.main.async {
                    self.notificationTime = triggerTime
                    self.schedulingNotificationEnabled = true
                }
            }
        }
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions)-> Void) {
        completionHandler([.alert, .badge, .sound])
    }

    private func requestPermissionPromise() -> Future<Bool, Never> {
        let authorize = Future<Bool, Never> { promise in
            UNUserNotificationCenter
                .current()
                .requestAuthorization(options: [.alert, .badge, .alert]) { granted, error in
                    DispatchQueue.main.async {
                        self.notificationsAuthorized = granted
                    }
                    if granted == true {
                        promise(.success(granted))
                    } else {
                        promise(.success(false))
                    }
            }
        }

        return authorize
    }

    public func requestNotificationAccess() {
        if !notificationsAuthorized {
            let requestFuture = requestPermissionPromise()
            requestCancellable = requestFuture
                .receive(on: DispatchQueue.main)
                .sink(receiveValue: { [weak self] authorizationStatus in
                    self?.notificationsAuthorized = authorizationStatus
                })
        }
    }

    public func scheduleNotification(at time: Date) {
        if notificationTime != time {
            notificationTime = time
        }

        // clear any old notifications
        cancelNotification()

        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            guard let strongSelf = self else { return }
            switch settings.authorizationStatus {
            case .notDetermined:
                strongSelf.requestNotificationAccess()
            case .authorized, .provisional:
                let content = UNMutableNotificationContent()
                content.title = strongSelf.notification.title
                content.body = strongSelf.notification.body
                content.categoryIdentifier = strongSelf.notificationCategoryIdentifier
                let assets = ContentFetcher.shared.fetchAssets(for: time)
                if let asset = assets.firstObject {
                    //if there's an asset for the notification, attach the associated thumbnail
                    self?.imageCancellable = ContentFetcher.shared.loadImage(asset: asset,
                                                                             quality: .opportunistic) { (progress, error, stop, info) in
                                                                                DispatchQueue.main.async {
                                                                                    //                                                self.loadingProgress = progress
                                                                                }
                    }
                    .receive(on: DispatchQueue.main)
                    .sink(receiveValue: { [weak self] image in
                        let url = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
                        let fileURL = url.appendingPathComponent("someImageName",
                                                                 isDirectory: false).appendingPathExtension("jpeg")
                        do {
                            try image.jpegData(compressionQuality: 1.0)?.write(to: fileURL)

                            if let notificationId = self?.notification.id,
                                let attachment = try? UNNotificationAttachment(identifier: notificationId,
                                                                         url: url,
                                                                         options: nil) {
                                // where myImage is any UIImage
                                content.attachments = [attachment]
                            }

                            let timeComponents = Calendar.current.dateComponents([.hour, .minute], from: time)
                            let trigger = UNCalendarNotificationTrigger(dateMatching: timeComponents, repeats: true)
                            let request = UNNotificationRequest(identifier: strongSelf.notification.id,
                                                                content: content,
                                                                trigger: trigger)
                            UNUserNotificationCenter.current().add(request) { [weak self] error in
                                guard error == nil else { return }
                                print("Scheduling notification with id: \(self?.notification.id ?? "Unknown Notification ID?!?")")
                            }

                        } catch {
                            print("Could not attach image: ", error)
                        }
                    })
                }

            default:
                break
            }
        }
    }

    public func cancelNotification() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        //        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notification.id])
    }
}
