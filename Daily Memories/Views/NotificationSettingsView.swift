//
//  NotificationSettingsView.swift
//  Daily Memories
//
//  Created by David Lewanda on 3/28/20.
//  Copyright © 2020 LewandaCode. All rights reserved.
//

import SwiftUI

struct NotificationSettingsView: View {
    @ObservedObject var notificationsManager = NotificationsManager.shared

    var body: some View {
        Group {
            if notificationsManager.notificationsAuthorized {
                VStack {
                    Text("Notification Settings").font(.largeTitle)
                    Toggle(isOn: $notificationsManager.schedulingNotificationEnabled) {
                        Text("Enable Notifications")
                    }

                    if notificationsManager.schedulingNotificationEnabled {
                        Text("Select a time to be reminded for your Daily Memories")
                        DatePicker("Reminder Time:",
                                   selection: $notificationsManager.notificationTime,
                                   displayedComponents: .hourAndMinute)
                        .labelsHidden()
                    }
                    Spacer()
                }
                .padding()
            } else {
                Text("You've disabled notification in Set$tings. Please re-enable to use this feature")
                // TODO: add button to deep link to the settings option
            }

        }
    }
}

struct NotificationSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationSettingsView()
    }
}
