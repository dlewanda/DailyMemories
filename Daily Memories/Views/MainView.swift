//
//  MainView.swift
//  Daily Memories
//
//  Created by David Lewanda on 3/2/20.
//  Copyright © 2020 LewandaCode. All rights reserved.
//

import SwiftUI
import Photos

struct MainView: View {
    @ObservedObject var imageFetcher = ImageFetcher.shared
    
    var body: some View {
        Group {
            if imageFetcher.authorizationStatus == .authorized {
                YearListView(yearlyAssetsArray: imageFetcher.yearlyAssets)
            } else {
                AuthorizationStatusView(authorizationStatus: imageFetcher.authorizationStatus)
            }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
