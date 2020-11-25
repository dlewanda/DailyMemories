//
//  Log.swift
//  DailyMemoriesSharedCode
//
//  Created by David Lewanda on 11/24/20.
//  Copyright © 2020 LewandaCode. All rights reserved.
//

import os

import os

private let subsystem = "com.lewandacode.Daily-Memories"

public struct Log {
  public static let notificationViewController = OSLog(subsystem: subsystem, category: "notificationViewController")
}
