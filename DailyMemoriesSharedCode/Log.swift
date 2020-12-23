//
//  Log.swift
//  DailyMemoriesSharedCode
//
//  Created by David Lewanda on 11/24/20.
//  Copyright © 2020 LewandaCode. All rights reserved.
//

import os

extension Logger {
    
    public static func logger<T>(for category: T.Type) -> Logger {
        return Logger(subsystem: Bundle.main.bundleIdentifier!,
                      category: String(describing: category))
    }

}
