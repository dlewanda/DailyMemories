//
//  YearListView.swift
//  Daily Memories
//
//  Created by David Lewanda on 2/22/20.
//  Copyright © 2020 LewandaCode. All rights reserved.
//

import Photos.PHAsset
import SwiftUI

struct YearListView: View {
    @State var yearlyAssetsArray: [YearlyAssets]
    @State var showingNotificationSettings = false

    var body: some View {
        NavigationView {
            Group {
                if yearlyAssetsArray.isEmpty {
                    VStack {
                        ImageView(image: Image(systemName: "photo.on.rectangle"))
                        Text("No Photos for Today").font(.largeTitle)
                    }
                    .padding()
                }
                else {
                    List {
                        ForEach(yearlyAssetsArray) { yearlyAssets in
                            Section(header: Text("\(yearlyAssets.yearString)")) {
                                ForEach(yearlyAssets.assets) { asset in
                                    //TODO Switch on asset type
                                    NavigationLink(destination: ContentDetailView(imageModel: ImageModel(asset: asset.phAsset,
                                                                                                         imageQuality: .highQualityFormat))) {
                                                                                                            ContentView(imageModel: ImageModel(asset: asset.phAsset,
                                                                                                                                               imageQuality: .highQualityFormat))
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationBarTitle(Text("Daily Memories").font(.largeTitle))
            .navigationBarItems(trailing: Button(action: {
                self.showingNotificationSettings.toggle()
                NotificationsManager.shared.requestNotificationAccess()
            }) {
                Image(systemName: "bell.circle.fill")
            }.sheet(isPresented: $showingNotificationSettings){
                return NotificationSettingsView()
            })

        }
//        .phoneOnlyStackNavigationView()
    }
}

struct YearListView_Previews: PreviewProvider {
    static var previews: some View {
        YearListView(yearlyAssetsArray: ImageFetcher.shared.yearlyAssets)
    }
}
