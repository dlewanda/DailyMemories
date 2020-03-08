//
//  YearListView.swift
//  Daily Memories
//
//  Created by David Lewanda on 2/22/20.
//  Copyright © 2020 LewandaCode. All rights reserved.
//

import SwiftUI

struct YearListView: View {
    let yearlyAssetsArray: [YearlyAssets]
    static let sectionHeaderFormat: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY"
        return formatter
    }()

    var body: some View {
        Group {
            if yearlyAssetsArray.isEmpty {
                VStack {
                    Image(systemName: "photo.on.rectangle")
                    Text("No Photos for Today")
                }
            }
            else {
                List {
                    ForEach(yearlyAssetsArray) { yearlyAssets in
                        Section(header: Text("\(yearlyAssets.year, specifier: "%4d")")) {
                            ForEach(yearlyAssets.assets) { asset in
                                //TODO Switch on asset type
                                ContentView(imageAsset: asset.phAsset)
                            }
                        }
                    }
                }
            }
        }
    }

}

struct YearListView_Previews: PreviewProvider {
    static var previews: some View {
        YearListView(yearlyAssetsArray: ImageFetcher.shared.fetchTestAssets())
    }
}
