//
//  YearListView.swift
//  Daily Memories
//
//  Created by David Lewanda on 4/22/20.
//  Copyright © 2020 LewandaCode. All rights reserved.
//

import SwiftUI
import Combine

struct YearListView: View {
    @ObservedObject var contentFetcher = ContentFetcher.shared

    var yearlyAssetsArray: [YearlyAssets] {
        contentFetcher.yearlyAssets
    }

    fileprivate func createNavigationLink(for asset: Asset) -> NavigationLink<ContentView, ContentDetailView> {
        //TODO Switch on asset type
        let assetModel: AssetModel

        switch asset.phAsset.mediaType {
        case .video:
            assetModel = VideoModel(asset: asset.phAsset)
        default:
            assetModel = ImageModel(asset: asset.phAsset, imageQuality: .highQualityFormat)

        }
        let contentDetailView = ContentDetailView(assetModel: assetModel)
        return NavigationLink(destination: contentDetailView) {
            ContentView(assetModel: assetModel)
        }
    }

    var body: some View {
        List {
            ForEach(yearlyAssetsArray) { yearlyAssets in
                Section(header: Text("\(yearlyAssets.yearString)")) {
                    ForEach(yearlyAssets.assets) { asset in
                        self.createNavigationLink(for: asset)
                    }
                }
            }
        }
    }
}

struct YearListView_Previews: PreviewProvider {
    static var previews: some View {
        YearListView()
    }
}
