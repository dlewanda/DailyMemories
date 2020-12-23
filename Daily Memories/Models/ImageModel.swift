//
//  ImageModel.swift
//  Daily Memories
//
//  Created by David Lewanda on 3/11/20.
//  Copyright © 2020 LewandaCode. All rights reserved.
//

import OSLog
import Photos
import UIKit
import Combine
import DailyMemoriesSharedCode

class ImageModel: AssetModel {

    @Published var image: UIImage?
    @Published var loadingError: Error?

    fileprivate func getImage() {
        ContentFetcher.shared.loadImage(asset: self.phAsset, quality: .highQualityFormat) { (progress, error, stop, info) in
            guard error == nil else {
                self.loadingError = error
                return
            }

            DispatchQueue.main.async {
                self.loadingProgress = progress
            }

        }
        .receive(on: DispatchQueue.main)
        .sink(receiveCompletion: { status in
            switch status {
            case .failure(let error):
                Logger.logger(for: Self.Type.self)
                    .log("ContentFetcher failed to load high-res image: \(error.localizedDescription)")
            case .finished:
                Logger.logger(for: Self.Type.self)
                    .log("ContentFetcher loaded high-res image successfully")
            }
        },
        receiveValue: { [weak self] image in
            self?.image = image
            self?.thumbnailImage = image //replace thumbnail when full-res image loads
        }).store(in: &cancellables)
    }

    public init(asset: PHAsset, imageQuality: PHImageRequestOptionsDeliveryMode) {
        super.init(asset: asset)
        getImage()
    }

}


