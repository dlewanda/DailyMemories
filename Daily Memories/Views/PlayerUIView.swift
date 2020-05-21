//
//  PlayerUIView.swift
//  Daily Memories
//
//  Created by David Lewanda on 5/9/20.
//  Copyright © 2020 LewandaCode. All rights reserved.
//

import UIKit
import AVKit

class PlayerUIView: UIView {
    private let playerLayer = AVPlayerLayer()
    init(assetURL: URL) {
        super.init(frame: .zero)

        let player = AVPlayer(url: assetURL)
//        player.play()

        playerLayer.player = player
        layer.addSublayer(playerLayer)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = bounds
    }
}
