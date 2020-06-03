//
//  ContentView.swift
//  Daily Memories
//
//  Created by David Lewanda on 2/17/20.
//  Copyright © 2020 LewandaCode. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var assetModel: AssetModel

    var body: some View {
        ZStack {
            ImageView(image: assetModel.image)
            VStack {
                Spacer()
                HStack {
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
