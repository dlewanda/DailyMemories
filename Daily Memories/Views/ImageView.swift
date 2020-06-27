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
    @State var image: UIImage = UIImage(systemName:"photo.on.rectangle")!
    var body: some View {
        Image(uiImage: image)
            .resizable()
            .aspectRatio(contentMode: .fit)
    }
}

struct ImageView_Previews: PreviewProvider {
    static var previews: some View {
        ImageView()
    }
}
