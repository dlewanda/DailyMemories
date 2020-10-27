//
//  PHAsset+DailyMemories.swift
//  DailyMemoriesSharedCode
//
//  Created by David Lewanda on 10/26/20.
//  Copyright © 2020 LewandaCode. All rights reserved.
//

import Photos

extension PHAsset {
    public var creationDateString: String {
        guard let creationDate = self.creationDate else {
            return "Unknown"
        }

        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .long

        return dateFormatter.string(from: creationDate)
    }

    public var year: Int {
        guard let creationDate = self.creationDate else {
            return 0
        }

        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current

        let components = calendar.dateComponents([.year], from: creationDate)
        return components.year ?? 0
    }
}
