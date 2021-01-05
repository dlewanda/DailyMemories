//
//  ContentView.swift
//  Daily Memories
//
//  Created by David Lewanda on 2/17/20.
//  Copyright © 2020 LewandaCode. All rights reserved.
//

import SwiftUI
import DailyMemoriesSharedCode

struct ContentView: View {
    @StateObject var assetModel: AssetModel

    var body: some View {
        ZStack {
            ImageView(image: $assetModel.thumbnailImage)
            VStack {
                Spacer()
                HStack {
                    if let loadingProgress = assetModel.loadingProgress,
                       loadingProgress < 1.0 {
                        ProgressView("Loading...",
                                     value: assetModel.loadingProgress,
                                     total: 1.0)
                            .foregroundColor(Color.white)
                            .padding()
                    }
                    Spacer()
                    Image(systemName: assetModel.assetTypeString)
                        .padding()
                        .foregroundColor(.white
                    )
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    
    static var previews: some View {
        ContentView(assetModel: ImageModel(asset: ContentFetcher.shared.fetchTestAsset(),
                                           imageQuality: .fastFormat))
    }
}
