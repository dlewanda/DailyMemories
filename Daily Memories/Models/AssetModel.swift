//
//  AssetModel.swift
//  Daily Memories
//
//  Created by David Lewanda on 5/24/20.
//  Copyright © 2020 LewandaCode. All rights reserved.
//

import Combine
import Photos
import MapKit
import SwiftUI

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

enum AssetTypeString: String {
    case unknown = "questionmark.square"
    case image = "photo"
    case video = "film"

    func uiImage() -> UIImage {
        return UIImage(systemName: self.rawValue)!
    }
}

class AssetModel: ObservableObject {
    var phAsset: PHAsset
    var cancellables = Set<AnyCancellable>()

    @Published var loadingProgress: Double = 0.0
    @Published var thumbnailImage: Image = Image(uiImage: UIImage(systemName: AssetTypeString.unknown.rawValue)!)

    public var assetTypeString: String {
        switch self {
        case is ImageModel:
            return AssetTypeString.image.rawValue
        case is VideoModel:
            return AssetTypeString.video.rawValue
        default:
            return AssetTypeString.unknown.rawValue
        }
    }

    public init(asset: PHAsset) {
        self.phAsset = asset
        if let newImage = UIImage(systemName: assetTypeString) {
            thumbnailImage = Image(uiImage: newImage)
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
            .sink(receiveValue: { [weak self] image in
                self?.thumbnailImage = Image(uiImage: image)
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
