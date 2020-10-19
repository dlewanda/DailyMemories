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
            return "Determining authorization status..."
        case .limited:
            return "You have limited authorization"
        @unknown default:
            return "Unknown status?!?"
        }
    }
    
    var body: some View {
        VStack {
            ImageView(image: .constant(UIImage(systemName: "photo.on.rectangle.fill")!))
            if authorizationStatus == .notDetermined {
                ProgressView(statusString)
            } else {
                Text(statusString)
                    .font(.title)
            }
        }
    }
}

struct AuthorizationErrorView_Previews: PreviewProvider {
    static var previews: some View {
        AuthorizationStatusView(authorizationStatus: ContentFetcher.shared.authorizationStatus)
    }
}
