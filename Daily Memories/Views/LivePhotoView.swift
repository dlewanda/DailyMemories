//
//  LivePhotoView.swift
//  Daily Memories
//
//  Created by David Lewanda on 6/29/20.
//  Copyright © 2020 LewandaCode. All rights reserved.
//

import SwiftUI
import Photos
import PhotosUI

 struct LivePhotoViewRepresentable : UIViewRepresentable {
    @Binding var livePhoto: PHLivePhoto

    init(livePhotoBinding: Binding<PHLivePhoto>) {
        self._livePhoto = livePhotoBinding
    }

    init(livePhoto: PHLivePhoto) {
        let livePhotoBinding = Binding<PHLivePhoto>(get: { () -> PHLivePhoto in
            livePhoto
        },
                                                set:  { (_) in
            // do nothing
        })

        self.init(livePhotoBinding: livePhotoBinding)
    }
    
    func makeUIView(context: Context) -> PHLivePhotoView {
        return PHLivePhotoView()
    }

    func updateUIView(_ uiView: PHLivePhotoView, context: Context) {
        uiView.livePhoto = livePhoto
    }
}

struct LivePhotoView : View {
    private var _livePhoto: PHLivePhoto?

    private init() {

    }

    init(livePhoto: PHLivePhoto) {
        _livePhoto = livePhoto
    }

    init(assetModel: AssetModel) {
        guard let livePhotoModel = assetModel as? LivePhotoModel,
              let livePhoto = livePhotoModel.livePhoto else {
            self.init()
            return
        }
        self.init(livePhoto: livePhoto)
    }

    var body: some View {
        VStack {
            if let livePhoto = _livePhoto {
                LivePhotoViewRepresentable(livePhoto: livePhoto)
            } else {
                Image(systemName: "livephoto")
            }
        }
    }
}

//TODO: Figure out how to preview here?
//struct LivePhotoView_Previews: PreviewProvider {
//    static var previews: some View {
//        LivePhotoView(url: URL(string: "https://bitdash-a.akamaihd.net/content/sintel/hls/playlist.m3u8")!)
//    }
//}
