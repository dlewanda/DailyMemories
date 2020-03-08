//
//  ContentView.swift
//  Daily Memories
//
//  Created by David Lewanda on 2/17/20.
//  Copyright © 2020 LewandaCode. All rights reserved.
//

import Photos
import SwiftUI

struct ContentView: View {
    let imageAsset: PHAsset

    private func requestOptions() -> PHImageRequestOptions {
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = true
        requestOptions.deliveryMode = .highQualityFormat
        return requestOptions
    }

    var creationDateString: String {
        guard let creationDate = imageAsset.creationDate else {
            return "Unknown"
        }

        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short

        return dateFormatter.string(from: creationDate)
    }


    private func loadImage(asset: PHAsset) -> UIImage {
        let manager = PHImageManager.default()

        var image: UIImage = UIImage()
        manager.requestImage(for: asset,
                             targetSize: CGSize(width: 900, height: 600),
                             contentMode: .aspectFit,
                             options: requestOptions()) { img, err  in
            // 3
            guard let img = img else { return }
                image = img
        }
        return image
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            Image(uiImage: loadImage(asset: imageAsset))
            Text("\(creationDateString)").foregroundColor(.white)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    
    static var previews: some View {
        ContentView(imageAsset: ImageFetcher.shared.fetchTestAsset())
    }
}
