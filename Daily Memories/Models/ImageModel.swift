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

class ImageModel: ObservableObject {
    @Published var image = UIImage(systemName: "photo")
    @Published var isLoading = true
    private var imageCancellable: Cancellable?
    private var phAsset: PHAsset

    public init(asset: PHAsset, imageQuality: PHImageRequestOptionsDeliveryMode) {
        self.phAsset = asset
        imageCancellable = ImageFetcher.shared.loadImage(asset: self.phAsset,
                                                         quality: imageQuality)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { image in
                self.isLoading = false
                self.image = image
            })
    }

    var creationDateString: String {
        phAsset.creationDateString
    }

    var coordinate: CLLocationCoordinate2D {
        phAsset.location?.coordinate ?? CLLocationCoordinate2D()
    }
}
