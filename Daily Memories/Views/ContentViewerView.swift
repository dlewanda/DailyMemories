//
//  ContentViewerView.swift
//  Daily Memories
//
//  Created by David Lewanda on 3/14/20.
//  Copyright © 2020 LewandaCode. All rights reserved.
//

import SwiftUI
import DailyMemoriesSharedCode

struct ContentViewerView: View {
    @StateObject var assetModel: AssetModel
    @State var scale: CGFloat = 1.0
    @State var currentPosition = CGSize.zero
    @State var newPosition = CGSize.zero

    private var isZoomed: Bool {
        return scale > 1.0
    }

    fileprivate func getUpdatedPosition(for translation: CGSize) -> CGSize {
        let newWidth = translation.width + self.newPosition.width
        let newHeight = translation.height + self.newPosition.height
        let newPosition = CGSize(width: newWidth, height: newHeight)
        return newPosition
    }

    fileprivate func updatePosition(for value: DragGesture.Value) {
        guard self.isZoomed else { return }
        let newPosition = self.getUpdatedPosition(for: value.translation)
        //only allow panning if not moving off screen
        guard newPosition.width < 0, newPosition.height < 0 else { return }
        self.currentPosition = newPosition
    }

    private var dragGesture: _EndedGesture<_ChangedGesture<DragGesture>> {
        DragGesture(coordinateSpace: .global)
            .onChanged({ value in
                self.updatePosition(for: value)
            })
            .onEnded( { value in
                self.updatePosition(for: value)
            })
    }

    private var magnificationGesture: _EndedGesture<_ChangedGesture<MagnificationGesture>> {
        MagnificationGesture()
            .onChanged({ value in
                // only allow zooming larger than default
                guard value.magnitude >= 1.0 else { return }
                self.scale = value.magnitude
            })
            .onEnded({ value in
                //self.newPosition = self.currentPosition
            })
    }

    @ViewBuilder private func assetView() -> some View {
        switch self.assetModel {
        case is VideoModel:
            VideoView(assetModel: assetModel)
        case is ImageModel:
            ImageView(assetModel: assetModel)
        case is LivePhotoModel:
            LivePhotoView(assetModel: assetModel)
        default:
            ImageView(image: self.$assetModel.thumbnailImage)
        }
    }

    var body: some View {
        VStack {

            Spacer()
            
            assetView()
                .offset(x: self.currentPosition.width, y: self.currentPosition.height)
                .scaleEffect(scale)
                .clipped()
                .onTapGesture(count: 2) {
                    withAnimation(.easeOut(duration: 0.3)) {
                        // reset size and position on double tap
                        self.scale = 1.0
                        self.currentPosition = CGSize.zero
                    }

                }
                .gesture(magnificationGesture.simultaneously(with: self.dragGesture))

            Spacer()
        }
    }
}

struct ContentViewerView_Previews: PreviewProvider {
    static var previews: some View {
        ContentViewerView(assetModel: ImageModel(asset: ContentFetcher.shared.fetchTestAsset(),
                                                 imageQuality: .fastFormat))
    }
}
