//
//  LivePhotoModel.swift
//  Daily Memories
//
//  Created by David Lewanda on 6/30/20.
//  Copyright © 2020 LewandaCode. All rights reserved.
//

import Combine
import PhotosUI

class LivePhotoModel: AssetModel {
    @Published var livePhoto: PHLivePhoto?

    fileprivate func getLivePhoto() {
        ContentFetcher.shared.loadLivePhoto(asset: self.phAsset)
            .receive(on: DispatchQueue.main)
            .replaceError(with: nil)
            .sink(receiveValue: { [weak self] livePhoto in
                self?.livePhoto = livePhoto
            }).store(in: &cancellables)
    }

    public override init(asset: PHAsset) {
        super.init(asset: asset)
        getLivePhoto()
    }
}
