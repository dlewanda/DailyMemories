//
//  YearListView.swift
//  Daily Memories
//
//  Created by David Lewanda on 2/22/20.
//  Copyright © 2020 LewandaCode. All rights reserved.
//

import Photos.PHAsset
import SwiftUI

struct YearListView: View {
    @State var yearlyAssetsArray: [YearlyAssets]

    private func createContentView(from asset: PHAsset) -> some View {
        return ContentView(imageModel: ImageModel(asset: asset))
            .navigationBarTitle(Text("\(asset.creationDateString)").font(.headline),
                                displayMode: .inline)
    }

    var body: some View {
        Group {
            if yearlyAssetsArray.isEmpty {
                VStack {
                    Image(systemName: "photo.on.rectangle")
                    Text("No Photos for Today")
                }
            }
            else {
                NavigationView {
                    List {
                        ForEach(yearlyAssetsArray) { yearlyAssets in
                            Section(header: Text("\(yearlyAssets.yearString)")) {
                                ForEach(yearlyAssets.assets) { asset in
                                    //TODO Switch on asset type
                                    NavigationLink(destination: ContentDetailView(imageModel: ImageModel(asset: asset.phAsset))) {
                                        ContentView(imageModel: ImageModel(asset: asset.phAsset))
                                    }
                                    .navigationBarTitle(Text("Daily Memories").font(.largeTitle))
                                }
                            }
                        }
                    }
                }
            }
        }
    }

}

struct YearListView_Previews: PreviewProvider {
    static var previews: some View {
        YearListView(yearlyAssetsArray: ImageFetcher.shared.yearlyAssets)
    }
}
