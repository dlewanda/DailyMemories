//
//  VideoView.swift
//  Daily Memories
//
//  Created by David Lewanda on 5/9/20.
//  Copyright © 2020 LewandaCode. All rights reserved.
//

import SwiftUI

struct VideoView: UIViewRepresentable {
    let assetURL: URL
    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<VideoView>) {
    }
    
    func makeUIView(context: Context) -> UIView {
        return PlayerUIView(assetURL: assetURL)
    }
}
