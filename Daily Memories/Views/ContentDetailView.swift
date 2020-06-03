//
//  ContentDetailView.swift
//  Daily Memories
//
//  Created by David Lewanda on 3/11/20.
//  Copyright © 2020 LewandaCode. All rights reserved.
//

import SwiftUI

struct ContentDetailView: View {
    @ObservedObject var assetModel: AssetModel
    @State var presentFullscreenImage = false

    var body: some View {
        VStack {
            HStack {
                Text(assetModel.creationDateString)
                Spacer()
                Image(systemName: assetModel.assetTypeString)
                //                Button(action: {
                //                    self.showingSheet = true
                //                }) {
                //                    Image(systemName: "square.and.arrow.up")
                //                }
                //                .sheet(isPrsented: $showingSheet,
                //                       content: {
                //                })
            }
            .padding()
            ImageView(image: assetModel.image)
                .onTapGesture(count: 2) {
                    self.presentFullscreenImage = true
            }
            MapView(coordinate: assetModel.coordinate)
        }
        .sheet(isPresented: $presentFullscreenImage) {
            ContentViewerView(image: self.assetModel.image,
                              presentImage: self.$presentFullscreenImage)
        }
    }
}

struct ContentDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ContentDetailView(assetModel: ImageModel(asset: ContentFetcher.shared.fetchTestAsset(),
                                                 imageQuality: .highQualityFormat))
    }
}
