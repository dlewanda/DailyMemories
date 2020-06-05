//
//  PlayerViewController.swift
//  Daily Memories
//
//  Created by David Lewanda on 06/04/20.
//  Copyright © 2020 LewandaCode. All rights reserved.
//

import AVKit
import SwiftUI

struct PlayerViewController: UIViewControllerRepresentable {

    let player: AVPlayer

    func makeUIViewController(context: UIViewControllerRepresentableContext<PlayerViewController>) -> AVPlayerViewController {
        let controller = AVPlayerViewController()

        controller.player = player
        return controller
    }

    func updateUIViewController(_ uiViewController: AVPlayerViewController,
                                context: UIViewControllerRepresentableContext<PlayerViewController>) {

    }
}
