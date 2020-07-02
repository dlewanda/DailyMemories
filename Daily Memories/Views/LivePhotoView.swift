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

 struct LivePhotoView : UIViewRepresentable {
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
