//
//  ContentView.swift
//  Daily Memories
//
//  Created by David Lewanda on 2/17/20.
//  Copyright © 2020 LewandaCode. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var imageModel: ImageModel

    var body: some View {
        Image(uiImage: imageModel.image ?? UIImage(systemName: "photo")!)
            .resizable()
            .aspectRatio(contentMode: .fit)
    }
}

struct ContentView_Previews: PreviewProvider {
    
    static var previews: some View {
        ContentView(imageModel: ImageModel(asset: ImageFetcher.shared.fetchTestAsset()))
    }
}
