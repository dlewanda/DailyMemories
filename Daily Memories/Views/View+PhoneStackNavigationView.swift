//
//  View+PhoneStackNavigationView.swift
//  Daily Memories
//
//  Created by David Lewanda on 3/14/20.
//  Copyright © 2020 LewandaCode. All rights reserved.
//

import SwiftUI

extension View {
    func phoneOnlyStackNavigationView() -> some View {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return AnyView(self.navigationViewStyle(StackNavigationViewStyle()))
        } else {
            return AnyView(self)
        }
    }
}

