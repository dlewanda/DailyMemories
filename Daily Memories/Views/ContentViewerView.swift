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
    @State var currentPosition = CGSize()
    @State var newPosition = CGSize()
    @Binding var presentImage: Bool

    private var dragGesture: _EndedGesture<_ChangedGesture<DragGesture>> {
        DragGesture().onChanged({ value in
            self.currentPosition = CGSize(width: value.translation.width + self.newPosition.width,
                                          height: value.translation.height + self.newPosition.height)
        })
            .onEnded( { value in
                self.currentPosition = CGSize(width: value.translation.width + self.newPosition.width,
                                              height: value.translation.height + self.newPosition.height)
                self.newPosition = self.currentPosition
            })
    }

    private var magnificationGesture: _ChangedGesture<MagnificationGesture> {
        MagnificationGesture()
        .onChanged { value in
            self.scale = value.magnitude
        }
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

            //            GeometryReader { geometry in
            //                ScrollView([.horizontal, .vertical]) {
            ImageView(image: image)
                .offset(x: self.currentPosition.width, y: self.currentPosition.height)
                .scaleEffect(scale)
                .clipped()
                .onTapGesture(count: 2) {
                    self.scale = 1.0
            }
            .gesture(magnificationGesture.simultaneously(with: self.dragGesture))
            //                }
            //            }

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
