//
//  ImageView.swift
//  Daily Memories
//
//  Created by David Lewanda on 3/14/20.
//  Copyright © 2020 LewandaCode. All rights reserved.
//

import SwiftUI

struct ContentViewerView: View {
    @State var image: Image
    @State var scale: CGFloat = 1.0
    @Binding var presentImage: Bool

    var imageView: some View {
        return image.resizable()
    }
    var body: some View {
        VStack {
            #if targetEnvironment(macCatalyst)
            HStack {
                Button(action: {
                    self.presentImage.toggle()
                }) {
                    Text("Dismiss")
                }
                Spacer()
            }
            .padding()
            #endif

            //                ScrollView([.horizontal, .vertical]) {
            ImageView(image: image)
                .offset(x: self.currentPosition.width, y: self.currentPosition.height)
                .scaleEffect(scale)
                .clipped()
                .onTapGesture(count: 2) {
                    self.scale = 1.0
            }
            //                }
            #if targetEnvironment(macCatalyst)
            Spacer()
            #endif
        }
    }
}

struct ContentViewerView_Previews: PreviewProvider {
    static var previews: some View {
        ContentViewerView(image: Image(systemName: "photo"), presentImage: .constant(true))
    }
}