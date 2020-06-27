//
//  ImageModel.swift
//  Daily Memories
//
//  Created by David Lewanda on 3/11/20.
//  Copyright © 2020 LewandaCode. All rights reserved.
//

import Photos
import UIKit

class ImageModel: AssetModel {

    @Published var image: UIImage?

    fileprivate func getImage() {
        ContentFetcher.shared.loadImage(asset: self.phAsset, quality: .highQualityFormat)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] image in
                self?.image = image
            }).store(in: &cancellables)
    }

    public init(asset: PHAsset, imageQuality: PHImageRequestOptionsDeliveryMode) {
        super.init(asset: asset)
        getImage()
    }

}


