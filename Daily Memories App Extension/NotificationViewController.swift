//
//  NotificationViewController.swift
//  Daily Memories App Extension
//
//  Created by David Lewanda on 7/2/20.
//  Copyright © 2020 LewandaCode. All rights reserved.
//

import os
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
            .sink(receiveCompletion: { [weak self] status in
                switch status {
                case .failure(let error):
                    Logger.logger(for: Self.Type.self)
                        .log("ContentFetcher failed to load image: \(error.localizedDescription)")
                    self?.imageView?.isHidden = true
                    self?.label?.text = "No memories for today"
                case .finished:
                    Logger.logger(for: Self.Type.self)
                        .log("ContentFetcher loaded image successfully")
                }
            }, receiveValue: { [weak self] (image, year) in
                self?.imageView?.image = image
                self?.label?.text = "Check out what happened in \(year)"
            })

    }

}
