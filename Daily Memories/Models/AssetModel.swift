//
//  AssetModel.swift
//  Daily Memories
//
//  Created by David Lewanda on 5/24/20.
//  Copyright © 2020 LewandaCode. All rights reserved.
//

import OSLog
import Combine
import Photos
import MapKit
import UIKit

import DailyMemoriesSharedCode


enum AssetTypeString: String {
    case unknown = "questionmark.square"
    case image = "photo"
    case video = "film"
    case livePhoto = "livephoto"

    func uiImage() -> UIImage {
        return UIImage(systemName: self.rawValue)!
    }
}

class AssetModel: ObservableObject {
    var phAsset: PHAsset
    var cancellables = Set<AnyCancellable>()

    @Published var loadingProgress: Double?
    @Published var thumbnailImage: UIImage = UIImage(systemName: AssetTypeString.unknown.rawValue)!

    public var assetTypeString: String {
        switch self {
        case is ImageModel:
            return AssetTypeString.image.rawValue
        case is VideoModel:
            return AssetTypeString.video.rawValue
        case is LivePhotoModel:
            return AssetTypeString.livePhoto.rawValue
        default:
            return AssetTypeString.unknown.rawValue
        }
    }

    public init(asset: PHAsset) {
        self.phAsset = asset
        if let newImage = UIImage(systemName: assetTypeString) {
            thumbnailImage = newImage
        }
        getThumbnail()
    }

    func getThumbnail() {
        ContentFetcher.shared.loadImage(asset: self.phAsset,
                                        quality: .opportunistic) { (progress, error, stop, info) in
                                            DispatchQueue.main.async {
                                                self.loadingProgress = progress
                                            }
        }
        .receive(on: DispatchQueue.main)
        .sink(receiveCompletion: { status in
            switch status {
            case .failure(let error):
                Logger.logger(for: Self.Type.self)
                    .log("ContentFetcher failed to load thumbnail image: \(error.localizedDescription)")
            case .finished:
                Logger.logger(for: Self.Type.self)
                    .log("ContentFetcher loaded thumbnail image successfully")
            }
        }, receiveValue: { [weak self] image in
            self?.thumbnailImage = image
        })
        .store(in: &cancellables)
    }

    var creationDateString: String {
        phAsset.creationDateString
    }

    var assetYear: String {
        String("\(phAsset.year)")
    }

    var coordinate: CLLocationCoordinate2D {
        phAsset.location?.coordinate ?? CLLocationCoordinate2D()
    }
}
