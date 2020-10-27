//
//  ContentDetailView.swift
//  Daily Memories
//
//  Created by David Lewanda on 3/11/20.
//  Copyright © 2020 LewandaCode. All rights reserved.
//

import SwiftUI
import DailyMemoriesSharedCode

struct ContentDetailView: View {
    @StateObject var assetModel: AssetModel
    @State private var showSheet = false
    
    var body: some View {
        VStack {
            HStack {
                Text(assetModel.creationDateString)
                Spacer()
                Button(action: {
                    showSheet = true
                }) {
                    Image(systemName: "square.and.arrow.up")
                }
                Image(systemName: assetModel.assetTypeString)
            }
            .padding()
            NavigationLink(destination: ContentViewerView(assetModel: self.assetModel)) {
                ImageView(image: $assetModel.thumbnailImage)
            }
            MapView(coordinate: assetModel.coordinate)
        }
        .sheet(isPresented: $showSheet) {
            ShareViewController(activityItems: ["Check out what happened today in \(self.assetModel.phAsset.year)",
                                                self.assetModel.thumbnailImage],
                                excludedActivityTypes: [.saveToCameraRoll])
        }
    }
}

struct ContentDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ContentDetailView(assetModel: ImageModel(asset: ContentFetcher.shared.fetchTestAsset(),
                                                 imageQuality: .highQualityFormat))
    }
}
