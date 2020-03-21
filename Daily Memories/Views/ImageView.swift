//
//  ImageView.swift
//  Daily Memories
//
//  Created by David Lewanda on 3/17/20.
//  Copyright © 2020 LewandaCode. All rights reserved.
//

import SwiftUI

struct ImageView: View {
    var image: Image
    var body: some View {
        image.resizable()
            .aspectRatio(contentMode: .fit)
    }
}

struct ImageView_Previews: PreviewProvider {
    static var previews: some View {
        ImageView(image: Image(systemName: "photo"))
    }
}
