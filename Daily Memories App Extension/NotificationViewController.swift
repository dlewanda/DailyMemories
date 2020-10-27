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
        let contentFetcher = ContentFetcher.shared

        let assets = contentFetcher.fetchAssets(for: Date())
        guard let firstAsset = assets.firstObject else {
            self.label?.text = "No memories for today"
            self.imageView?.isHidden = true
            return
        }

        self.label?.text = notification.request.content.body
        self.loadCancellable = contentFetcher.loadImage(asset: firstAsset,
                                                        quality: .opportunistic) { (progress, error, stop, info) in
            DispatchQueue.main.async {
//                                                                self.loadingProgress = progress
            }
        }
        .receive(on: DispatchQueue.main)
        .sink(receiveValue: { [weak self] image in
            self?.imageView?.image = image
        })
    }

}
