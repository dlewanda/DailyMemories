//
//  ImageModel.swift
//  Daily Memories
//
//  Created by David Lewanda on 3/11/20.
//  Copyright © 2020 LewandaCode. All rights reserved.
//

import Combine
import Photos
import MapKit
import UIKit

extension PHAsset {
    var creationDateString: String {
        guard let creationDate = self.creationDate else {
            return "Unknown"
        }

        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .long

        return dateFormatter.string(from: creationDate)
    }
}

class AssetModel: ObservableObject {
    @Published var isLoading = true
    @Published var image: UIImage = UIImage(systemName: "questionmark.square")!

    var phAsset: PHAsset
    var cancellables = Set<AnyCancellable>()

    public init(asset: PHAsset) {
        self.phAsset = asset
        getImage(.highQualityFormat)
    }

    func getImage(_ imageQuality: PHImageRequestOptionsDeliveryMode) {
        ContentFetcher.shared.loadImage(asset: self.phAsset,
                                        quality: imageQuality)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] image in
                self?.isLoading = false
                self?.image = image
            })
            .store(in: &cancellables)
    }

    var creationDateString: String {
        phAsset.creationDateString
    }

    var coordinate: CLLocationCoordinate2D {
        phAsset.location?.coordinate ?? CLLocationCoordinate2D()
    }
}

class ImageModel: AssetModel {
    public init(asset: PHAsset, imageQuality: PHImageRequestOptionsDeliveryMode) {
        super.init(asset: asset)
        image = UIImage(systemName: "photo")!
    }
}

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
