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

    private var cancellables = Set<AnyCancellable>()
    var fetchedEntry: MemoryEntry?
    private var loadCancellable: Cancellable?

    func placeholder(in context: Context) -> MemoryEntry {
        MemoryEntry.placeholder
    }

    func getSnapshot(in context: Context, completion: @escaping (MemoryEntry) -> ()) {
        if let entry = fetchedEntry {
            completion(entry)
        } else {
            completion(MemoryEntry.placeholder)
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let date = Date()
        ContentFetcher.shared.getImageFor(date: date) { uiImage, year in
            // TODO: Replace force cast?
            let uiImage = uiImage ?? UIImage(systemName: "nosign")!
            let image = Image(uiImage: uiImage)

            // Create a timeline entry for "now."
            let entry = MemoryEntry(
                date: date,
                year: year,
                image: image
            )

            // Create a date that starts at the start of tomorrow
            let calendar = Calendar.current
            let nextUpdateDate = calendar.startOfDay(for: calendar.date(byAdding: .day, value: 1, to: date)!)

            // Create the timeline with the entry and a reload policy with the date
            // for the next update.
            let timeline = Timeline(
                entries:[entry],
                policy: .after(nextUpdateDate)
            )

            // Call the completion to pass the timeline to WidgetKit.
            completion(timeline)
        }
    }

}

struct MemoryEntry: TimelineEntry {
    let date: Date
    let year: Int
    let image: Image

    static let defaultImage = Image(systemName: "photo")

    static var placeholder: MemoryEntry {
        MemoryEntry(date: Date(), year: -1, image: MemoryEntry.defaultImage)
    }
}

struct DailyMemoriesWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        ZStack {
            entry.image
                .resizable()
                .aspectRatio(contentMode: .fill)
            VStack {
                Spacer()
                Text(entry.year > 2000 ? "Today in \(String(entry.year))" : "")
                    .foregroundColor(Color.white)
            }.padding([.bottom], 30)
        }
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
                                                        year: 2020,
                                                        image: MemoryEntry.defaultImage))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}

