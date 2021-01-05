//
//  VideoView.swift
//  Daily Memories
//
//  Created by David Lewanda on 6/2/20.
//  Copyright © 2020 LewandaCode. All rights reserved.
//

import AVKit
import SwiftUI

struct VideoView: View {
    private let player: AVPlayer

    init(url: URL) {
        player = AVPlayer(url: url)
    }

    init(assetModel: AssetModel) {
        guard let videoModel = assetModel as? VideoModel,
              let urlAsset = videoModel.urlAsset else {
            self.init()
            return
        }
        self.init(url: urlAsset.url)
    }

    private init() {
        player = AVPlayer()
    }

    var body: some View {
        VStack {
          PlayerViewController(player: player)
        }
    }
}

struct VideoView_Previews: PreviewProvider {
    static var previews: some View {
        VideoView(url: URL(string: "https://bitdash-a.akamaihd.net/content/sintel/hls/playlist.m3u8")!)
    }
}
