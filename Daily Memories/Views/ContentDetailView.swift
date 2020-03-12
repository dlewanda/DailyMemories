//
//  ContentDetailView.swift
//  Daily Memories
//
//  Created by David Lewanda on 3/11/20.
//  Copyright © 2020 LewandaCode. All rights reserved.
//

import SwiftUI

struct ContentDetailView: View {
    @ObservedObject var imageModel: ImageModel

    var body: some View {
        VStack {
            HStack {
                Text(imageModel.creationDateString)
                Spacer()
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
            Image(uiImage: imageModel.image ?? UIImage(systemName: "photo")!)
                .resizable()
                .aspectRatio(contentMode: .fit)
            MapView(coordinate: imageModel.coordinate)
        }
    }
}

struct ContentDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ContentDetailView(imageModel: ImageModel(asset: ImageFetcher.shared.fetchTestAsset()))
    }
}
