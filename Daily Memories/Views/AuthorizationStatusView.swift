//
//  AuthorizationErrorView.swift
//  Daily Memories
//
//  Created by David Lewanda on 3/2/20.
//  Copyright © 2020 LewandaCode. All rights reserved.
//

import SwiftUI
import Photos

struct AuthorizationStatusView: View {
    @State var authorizationStatus: PHAuthorizationStatus
    
    var statusString: String {
        switch authorizationStatus {
        case .authorized:
            return "You are authorized!"
        case .denied:
            return "You have denied access to your photos. Please update in Settings."
        case .restricted:
            return "You are not allowed to access your photos through this app."
        case .notDetermined:
            return "Authorization not yet determined"
        @unknown default:
            return "Unknown status?!?"
        }
    }
    
    var body: some View {
        VStack {
            Image(systemName: "photo.on.rectangle.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
            Text(statusString)
                .font(.title)
        }
    }
}

struct AuthorizationErrorView_Previews: PreviewProvider {
    static var previews: some View {
        AuthorizationStatusView(authorizationStatus: ImageFetcher.shared.authorizationStatus)
    }
}
