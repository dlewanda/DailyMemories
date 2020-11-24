//
//  NotificationViewController.swift
//  Daily Memories App Extension
//
//  Created by David Lewanda on 7/2/20.
//  Copyright © 2020 LewandaCode. All rights reserved.
//

import UIKit
import UserNotifications
import UserNotificationsUI
import Combine
import DailyMemoriesSharedCode

class NotificationViewController: UIViewController, UNNotificationContentExtension {

    @IBOutlet var label: UILabel?
    @IBOutlet weak var imageView: UIImageView?
    private var loadCancellable: Cancellable?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any required interface initialization here.
    }
    
    func didReceive(_ notification: UNNotification) {

        loadCancellable = ContentFetcher.shared.getImageFor(date: Date())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] error in
                self?.imageView?.isHidden = true
                self?.label?.text = "No memories for today"
            }, receiveValue: { [weak self] (image, year) in
                self?.imageView?.image = image
                self?.label?.text = "Check out what happened in \(year)"
            })

    }

}
