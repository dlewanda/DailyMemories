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
    private var phAsset: PHAsset = PHAsset()
    private var imageCancellable: Cancellable?

    public init(asset: PHAsset) {
        self.phAsset = asset
        imageCancellable = ImageFetcher.shared.loadImage(asset: self.phAsset)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { image in
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
