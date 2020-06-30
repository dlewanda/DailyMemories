//
//  YearListView.swift
//  Daily Memories
//
//  Created by David Lewanda on 2/22/20.
//  Copyright © 2020 LewandaCode. All rights reserved.
//

import Photos.PHAsset
import SwiftUI

struct YearNavigationView: View {
    @ObservedObject var imageFetcher = ContentFetcher.shared

    var yearlyAssetsArray: [YearlyAssets] {
        imageFetcher.yearlyAssets
    }

    @State var showingNotificationSettings = false

    var body: some View {
        NavigationView {
            Group {
                if yearlyAssetsArray.isEmpty {
                    VStack {
                        ImageView(image: ImageView.defaultImage())
                        Text("No Memories for Today").font(.largeTitle)
                    }
                    .padding()
                }
                else {
                    YearListView()
                }
            }
            .navigationBarTitle(Text("Daily Memories").font(.largeTitle))
            .navigationBarItems(
                leading: Button(action: {
                    self.imageFetcher.refreshAssets()
                }) {
                    Image(systemName:"arrow.up.arrow.down.circle.fill").font(.largeTitle)
                },
                trailing: Button(action: {
                    self.showingNotificationSettings.toggle()
                    NotificationsManager.shared.requestNotificationAccess()
                }) {
                    Image(systemName: "bell.circle.fill").font(.largeTitle)
                }.sheet(isPresented: $showingNotificationSettings){
                    return NotificationSettingsView(showSettings: self.$showingNotificationSettings)
            })

        }
        .phoneOnlyStackNavigationView()
    }
}

struct YearNavigationView_Previews: PreviewProvider {
    static var previews: some View {
        YearNavigationView()
    }
}
