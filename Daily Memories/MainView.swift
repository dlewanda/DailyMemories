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
                YearListView(yearlyAssetsArray: ImageFetcher.shared.fetchAssetsFor(date: Date()))
            } else {
                AuthorizationStatusView()
            }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
