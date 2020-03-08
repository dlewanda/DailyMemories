//
//  ImageFetcher.swift
//  Daily Memories
//
//  Created by David Lewanda on 2/17/20.
//  Copyright © 2020 LewandaCode. All rights reserved.
//

import Photos
import Combine

struct Asset: Identifiable {
    var id = UUID()
    let phAsset: PHAsset
}

struct YearlyAssets: Identifiable {
    var id = UUID()

    let year: Int
    var assets: [Asset] = [Asset]()
}

class ImageFetcher: ObservableObject {
    @Published var authorizationStatus = PHAuthorizationStatus.notDetermined
    private var requestCancellable: Cancellable?

    public func requestPhotoAccess() {
        let requestFuture = requestPhotosAccessPromise()
        requestCancellable = requestFuture
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { authorizationStatus in
                self.authorizationStatus = authorizationStatus
            })
    }

    private func fetchOldestAsset() -> PHAsset? {
        var phAsset = PHAsset()
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key:"creationDate", ascending: true)]
        fetchOptions.fetchLimit = 1

        // Fetch the image assets
        let fetchResult: PHFetchResult = PHAsset.fetchAssets(with: PHAssetMediaType.image,
                                                             options: fetchOptions)

        guard fetchResult.count > 0 else {
            return nil
        }
        phAsset = fetchResult[0]

        return phAsset
    }

    public static let shared = ImageFetcher()

    private func requestPhotosAccessPromise() -> Future<PHAuthorizationStatus, Never> {
        let authorize = Future<PHAuthorizationStatus, Never> { promise in
            switch PHPhotoLibrary.authorizationStatus() {
            case .authorized:
                promise(.success(.authorized))
            case .denied:
                return promise(.success(.denied))
            case .notDetermined:
                PHPhotoLibrary.requestAuthorization { status in
                    return promise(.success(status))
                }
            case .restricted:
                return promise(.success(.restricted))
            @unknown default:
                print("unknown authorization status")
                return promise(.success(.restricted))
            }

        }

        return authorize
    }

    public func fetchAssetsFor(date: Date = Date()) -> [YearlyAssets] {
        
        var assets = [YearlyAssets]()

        guard let oldestAsset = fetchOldestAsset(), let oldestAssetDate = oldestAsset.creationDate else {
            return assets
        }

        var photoDate = date
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current
        let today = Date()
        let components = calendar.dateComponents([.year, .month, .day], from: today)
        let month = components.month ?? 0
        let day = components.day ?? 0
        var year = components.year ?? 0

        while photoDate >= oldestAssetDate {
            let startOfDay = calendar.startOfDay(for: photoDate)
            let endOfDay = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: photoDate)!
            let todayPhotoOptions = PHFetchOptions()
            todayPhotoOptions.predicate = NSPredicate(format: "creationDate > %@ AND creationDate < %@",
                                                      startOfDay as NSDate,
                                                      endOfDay as NSDate)
            todayPhotoOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]

            let todayPhotos: PHFetchResult<PHAsset> = PHAsset.fetchAssets(with: todayPhotoOptions)

            if todayPhotos.count > 0 {
                var yearlyAssets = YearlyAssets(year: year)

                print("-----------")
                print("\(photoDate) photo count: \(todayPhotos.count)")
                todayPhotos.enumerateObjects { (asset, index, stop) in
                    yearlyAssets.assets.append(Asset(phAsset: asset))
                }
                assets.append(yearlyAssets)
                print("-----------")
            }
            year -= 1
            photoDate = calendar.date(from: DateComponents(year:year, month: month, day: day, hour: 0, minute: 0, second: 0))!
        }

        return assets
    }
}


// MARK: -
// MARK: Test Functions
extension ImageFetcher {
    public func fetchTestAssets() -> [YearlyAssets] {
        guard let oldestAssetDate = fetchOldestAsset()?.creationDate else {
            return [YearlyAssets]()
        }

        return fetchAssetsFor(date: oldestAssetDate)
    }

    public func fetchTestYearlyAssets() -> YearlyAssets {
        return fetchTestAssets().first ?? YearlyAssets(year: 2020)
    }

    public func fetchTestAsset() -> PHAsset {
        return fetchOldestAsset() ?? PHAsset()
    }
}
