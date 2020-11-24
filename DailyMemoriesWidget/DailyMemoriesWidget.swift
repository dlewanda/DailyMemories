//
//  DailyMemoriesWidget.swift
//  DailyMemoriesWidget
//
//  Created by David Lewanda on 11/23/20.
//  Copyright © 2020 LewandaCode. All rights reserved.
//

import WidgetKit
import SwiftUI
import Combine
import DailyMemoriesSharedCode

struct Provider: TimelineProvider {
    private var loadCancellable: Cancellable?

    func placeholder(in context: Context) -> MemoryEntry {
        MemoryEntry(date: Date(), image: MemoryEntry.defaultImage)
    }

    func getSnapshot(in context: Context, completion: @escaping (MemoryEntry) -> ()) {
        let entry = getLatestImage()
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [MemoryEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = MemoryEntry(date: entryDate, image: MemoryEntry.defaultImage)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }

    func getLatestImage() -> MemoryEntry {
//
        let contentFetcher = ContentFetcher.shared
//
//        let assets = contentFetcher.mostRecentAssetForThis(date: Date())
//        guard let firstAsset = assets.firstObject else {
//            return MemoryEntry(date: Date(), image: Image(systemName: "nosign"))
//        }
//
//        loadCancellable = contentFetcher.loadImage(asset: firstAsset,
//                                                   quality: .opportunistic) { (progress, error, stop, info) in
//            DispatchQueue.main.async {
////                                                                self.loadingProgress = progress
//            }
//        }
//        .receive(on: DispatchQueue.main)
//        .sink(receiveValue: { image in
//            return MemoryEntry(date: Date(), image: Image(uiImage: image))
//        })
        return MemoryEntry(date: Date(), image: MemoryEntry.defaultImage)
    }

struct MemoryEntry: TimelineEntry {
    let date: Date
    let image: Image

    // TODO: Replace force unwrap?
    static let defaultImage = Image(systemName: "photo")
}

struct DailyMemoriesWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        VStack {
            entry.image
                .resizable()
                .aspectRatio(contentMode: .fit)
            Text(entry.date, style: .date)
        }.padding()
    }
}

@main
struct DailyMemoriesWidget: Widget {
    let kind: String = "DailyMemoriesWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            DailyMemoriesWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Daily Memories Widget")
        .description("The most recent memory on today's date")
    }
}

struct DailyMemoriesWidget_Previews: PreviewProvider {
    static var previews: some View {
        DailyMemoriesWidgetEntryView(entry: MemoryEntry(date: Date(),
                                                        image: MemoryEntry.defaultImage))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
    }
}
