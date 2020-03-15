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
    @State var presentFullscreenImage = false

    var image: Image {
        Image(uiImage: imageModel.image ?? UIImage(systemName: "photo")!)
    }

    var imageView: some View {
        image.resizable().aspectRatio(contentMode: .fit)
    }

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
            imageView.onTapGesture(count: 2) {
                self.presentFullscreenImage = true
            }
            MapView(coordinate: imageModel.coordinate)
        }
        .sheet(isPresented: $presentFullscreenImage) {
            ImageView(image: self.image, presentImage: self.$presentFullscreenImage)
        }
    }
}

struct ContentDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ContentDetailView(imageModel: ImageModel(asset: ImageFetcher.shared.fetchTestAsset()))
    }
}
