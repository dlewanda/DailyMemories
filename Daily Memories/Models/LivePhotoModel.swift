//
//  LivePhotoModel.swift
//  Daily Memories
//
//  Created by David Lewanda on 6/30/20.
//  Copyright © 2020 LewandaCode. All rights reserved.
//

import OSLog
import Combine
import PhotosUI
import DailyMemoriesSharedCode

class LivePhotoModel: AssetModel {
    @Published var livePhoto: PHLivePhoto?

    fileprivate func getLivePhoto() {
        ContentFetcher.shared.loadLivePhoto(asset: self.phAsset)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { status in
                switch status {
                case .failure(let error):
                    Logger.logger(for: Self.Type.self)
                        .log("ContentFetcher failed to load live phto image: \(error.localizedDescription)")
                case .finished:
                    Logger.logger(for: Self.Type.self)
                        .log("ContentFetcher loaded live photo successfully")
                }
            },
            receiveValue: { [weak self] livePhoto in
                self?.livePhoto = livePhoto
            }).store(in: &cancellables)
    }

    public override init(asset: PHAsset) {
        super.init(asset: asset)
        getLivePhoto()
    }
}
