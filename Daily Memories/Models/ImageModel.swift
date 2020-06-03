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
    public init(asset: PHAsset, imageQuality: PHImageRequestOptionsDeliveryMode) {
        super.init(asset: asset)
    }
}


