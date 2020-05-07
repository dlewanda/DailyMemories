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
    @ObservedObject var imageFetcher = ImageFetcher.shared

    var yearlyAssetsArray: [YearlyAssets] {
        imageFetcher.yearlyAssets
    }

    fileprivate func createContentView(for imageModel: ImageModel) -> ContentView {
        return ContentView(imageModel: imageModel)
    }

    fileprivate func createNavigationLink(for asset: Asset) -> NavigationLink<ContentView, ContentDetailView> {
        //TODO Switch on asset type
        let imageModel = ImageModel(asset: asset.phAsset, imageQuality: .highQualityFormat)
        let contentDetailView = ContentDetailView(imageModel: imageModel)
        return NavigationLink(destination: contentDetailView) {
            createContentView(for: imageModel)
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
