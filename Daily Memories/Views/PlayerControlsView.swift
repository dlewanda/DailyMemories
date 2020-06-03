//
//  PlayerControlsView.swift
//  Daily Memories
//
//  Created by David Lewanda on 6/2/20.
//  Copyright © 2020 LewandaCode. All rights reserved.
//

import AVKit
import SwiftUI

struct PlayerControlsView: View {
    @State var playerPaused = true
    let player: AVPlayer

    var body: some View {
      Button(action: {
        self.playerPaused.toggle()
        if self.playerPaused {
          self.player.pause()
        }
        else {
          self.player.play()
        }
      }) {
        Image(systemName: playerPaused ? "play" : "pause")
      }
    }
}

struct PlayerControlsView_Previews: PreviewProvider {
    static var previews: some View {
        PlayerControlsView(player: AVPlayer(url: URL(string: "https://bitdash-a.akamaihd.net/content/sintel/hls/playlist.m3u8")!))
    }
}
