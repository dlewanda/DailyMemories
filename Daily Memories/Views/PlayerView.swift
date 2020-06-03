//
//  PlayerView.swift
//  Daily Memories
//
//  Created by David Lewanda on 5/9/20.
//  Copyright © 2020 LewandaCode. All rights reserved.
//

import AVKit
import SwiftUI

struct PlayerView: UIViewRepresentable {
    let player: AVPlayer
    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<PlayerView>) {
    }
    
    func makeUIView(context: Context) -> UIView {
        return PlayerUIView(player: player)
    }
}
