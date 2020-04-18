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
}

class NotificationsManager: ObservableObject {
    static let shared = NotificationsManager()

    @Published var notificationsAuthorized: Bool = false
    @Published var schedulingNotificationEnabled: Bool = false {
        didSet {
            if schedulingNotificationEnabled {
                if notificationTime == Date.distantFuture {
                    // if enabled but no date set, schedule one for right now
                    scheduleNotification(at: Date())
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

    private var notification = Notification(id: UUID().uuidString,
                                            title: "Time for your daily trip down memory lane!")
    private var requestCancellable: Cancellable?

    private init() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            for request in requests {
                guard let calendarTrigger = request.trigger as? UNCalendarNotificationTrigger,
                let triggerTime = Calendar.current.date(from: calendarTrigger.dateComponents) else {
                    break
                }

                self.notificationTime = triggerTime
                self.schedulingNotificationEnabled = true
            }
        }
    }

    private func requestPermissionPromise() -> Future<Bool, Never> {
        let authorize = Future<Bool, Never> { promise in
            UNUserNotificationCenter
                .current()
                .requestAuthorization(options: [.alert, .badge, .alert]) { granted, error in
                    self.notificationsAuthorized = granted
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
        let requestFuture = requestPermissionPromise()
        requestCancellable = requestFuture
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] authorizationStatus in
                self?.notificationsAuthorized = authorizationStatus
            })
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
                
                let timeComponents = Calendar.current.dateComponents([.hour, .minute], from: time)
                let trigger = UNCalendarNotificationTrigger(dateMatching: timeComponents, repeats: true)
                let request = UNNotificationRequest(identifier: strongSelf.notification.id,
                                                    content: content,
                                                    trigger: trigger)
                UNUserNotificationCenter.current().add(request) { [weak self] error in
                    guard error == nil else { return }
                    print("Scheduling notification with id: \(self?.notification.id ?? "Unknown Notification ID?!?")")
                }

            default:
                break
            }
        }
    }

    public func cancelNotification() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notification.id])
    }
}
