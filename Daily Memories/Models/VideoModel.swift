//
//  VideoModel.swift
//  Daily Memories
//
//  Created by David Lewanda on 5/24/20.
//  Copyright © 2020 LewandaCode. All rights reserved.
//

import Combine
import Photos
import AVKit

class VideoModel: AssetModel {
    @Published var avAsset: AVAsset?

    fileprivate func getVideo() {
        ContentFetcher.shared.loadVideo(asset: self.phAsset)
            .receive(on: DispatchQueue.main)
            .replaceError(with: nil)
            .sink(receiveValue: { [weak self] avAsset in
                self?.isLoading = false
                self?.avAsset = avAsset
            }).store(in: &cancellables)
    }

    public override init(asset: PHAsset) {
        super.init(asset: asset)
        image = UIImage(systemName: "film")!
        getVideo()
    }
}
