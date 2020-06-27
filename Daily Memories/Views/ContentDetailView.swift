//
//  ContentDetailView.swift
//  Daily Memories
//
//  Created by David Lewanda on 3/11/20.
//  Copyright © 2020 LewandaCode. All rights reserved.
//

import SwiftUI

enum SheetType {
    case contentViewer
    case share
}

struct ContentDetailView: View {
    @ObservedObject var assetModel: AssetModel
    @State var showSheet = false
    @State var sheet: SheetType = .contentViewer

    private func sheetToShow() -> some View {
        let assetView: AnyView

        switch sheet {
        case .contentViewer:
            assetView = AnyView(ContentViewerView(assetModel: self.assetModel,
                                                  presentImage: self.$showSheet))
        case .share:
            assetView = AnyView(ShareViewController(activityItems: ["Share your Daily Memory",
                                                                    self.$assetModel.thumbnailImage],
                                                    excludedActivityTypes: [.saveToCameraRoll]))
        }
        return assetView
    }
    
    var body: some View {
        VStack {
            HStack {
                Text(assetModel.creationDateString)
                Spacer()
                Button(action: {
                    self.showSheet = true
                    self.sheet = .share
                }) {
                    Image(systemName: "square.and.arrow.up")
                }
                Image(systemName: assetModel.assetTypeString)
            }
            .padding()
            ImageView(image: assetModel.thumbnailImage)
                .onTapGesture(count: 2) {
                    self.showSheet = true
                    self.sheet = .contentViewer
            }
            MapView(coordinate: assetModel.coordinate)
        }
        .sheet(isPresented: $showSheet) {
            self.sheetToShow()
        }
    }
}

struct ContentDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ContentDetailView(assetModel: ImageModel(asset: ContentFetcher.shared.fetchTestAsset(),
                                                 imageQuality: .highQualityFormat))
    }
}
