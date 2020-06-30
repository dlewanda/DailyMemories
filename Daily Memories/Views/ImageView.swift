//
//  ImageView.swift
//  Daily Memories
//
//  Created by David Lewanda on 3/17/20.
//  Copyright © 2020 LewandaCode. All rights reserved.
//

import UIKit
import SwiftUI

struct ImageView: View {
    @Binding var image: UIImage //= .constant(UIImage(systemName: "photo.on.rectangle")!)
    var body: some View {
        Image(uiImage: image)
            .resizable()
            .aspectRatio(contentMode: .fit)
    }

    init(image: Binding<UIImage>) {
        self._image = image
    }

    init(uiImage: UIImage) {
        let bindingImage = Binding<UIImage>(get: { () -> UIImage in
            uiImage
        },
                                            set: { (_) in
                                                // do nothing
        })

        self.init(image: bindingImage)
    }

    static func defaultImage() -> Binding<UIImage> {
        .constant(UIImage(systemName: "photo.on.rectangle")!)
    }
}

struct ImageView_Previews: PreviewProvider {
    static var previews: some View {
        ImageView(image: ImageView.defaultImage())
    }
}
