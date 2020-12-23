//
//  NotificationManager.swift
//  Daily Memories
//
//  Created by David Lewanda on 3/28/20.
//  Copyright © 2020 LewandaCode. All rights reserved.
//

import OSLog
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
                setupNotification()
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
        completionHandler([.banner, .badge, .sound])
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
    }

    private func setupNotification() {
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

                let timeComponents = Calendar.current.dateComponents([.hour, .minute],
                                                                     from: strongSelf.notificationTime)
                let trigger = UNCalendarNotificationTrigger(dateMatching: timeComponents, repeats: true)
                let request = UNNotificationRequest(identifier: strongSelf.notification.id,
                                                    content: content,
                                                    trigger: trigger)
                UNUserNotificationCenter.current().add(request) { [weak self] error in
                    guard error == nil else { return }
                    Logger.logger(for: Self.Type.self)
                        .log("Scheduling notification with id: \(self?.notification.id ?? "Unknown Notification ID?!?")")
                }

            default:
                break
            }
        }
    }

    public func cancelNotification() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}
