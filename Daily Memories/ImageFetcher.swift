//
//  ImageFetcher.swift
//  Daily Memories
//
//  Created by David Lewanda on 2/17/20.
//  Copyright © 2020 LewandaCode. All rights reserved.
//

import Photos
import Combine
import UIKit

struct Asset: Identifiable {
    var id = UUID()
    let phAsset: PHAsset
}

struct YearlyAssets: Identifiable {
    var id = UUID()

    static var sectionHeaderFormat: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.usesGroupingSeparator = false
        return formatter
    }

    let year: Int
    var assets: [Asset] = [Asset]()

    var yearString: String {
        return Self.sectionHeaderFormat.string(from: NSNumber(value: year)) ?? "-----"
    }
}

extension PHAsset {
    var creationDateString: String {
        guard let creationDate = self.creationDate else {
            return "Unknown"
        }

        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .long

        return dateFormatter.string(from: creationDate)
//        return creationDate.description(with: Locale.current)
    }
}

class ImageFetcher: ObservableObject {
    public static let shared = ImageFetcher()

    @Published var authorizationStatus = PHAuthorizationStatus.notDetermined
    @Published var yearlyAssets: [YearlyAssets] = [YearlyAssets]()
    private var requestCancellable: Cancellable?

    public func requestPhotoAccess() {
        let requestFuture = requestPhotosAccessPromise()
        requestCancellable = requestFuture
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] authorizationStatus in
                self?.authorizationStatus = authorizationStatus
                if let strongSelf = self, strongSelf.authorizationStatus == .authorized {
                    strongSelf.yearlyAssets = strongSelf.fetchAssetsFor(date: Date())
                }
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

    private func requestPhotosAccessPromise() -> Future<PHAuthorizationStatus, Never> {
        let authorize = Future<PHAuthorizationStatus, Never> { promise in
            switch PHPhotoLibrary.authorizationStatus() {
            case .authorized:
                promise(.success(.authorized))
            case .denied:
                promise(.success(.denied))
            case .notDetermined:
                PHPhotoLibrary.requestAuthorization { status in
                   promise(.success(status))
                }
            case .restricted:
                promise(.success(.restricted))
            @unknown default:
                print("unknown authorization status")
                promise(.success(.restricted))
            }

        }

        return authorize
    }

    private func fetchAssetsFor(date: Date = Date()) -> [YearlyAssets] {
        
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

    public func loadImage(asset: PHAsset, quality: PHImageRequestOptionsDeliveryMode) -> Future<UIImage, Never> {
        let requestOptions = PHImageRequestOptions()
        requestOptions.deliveryMode = quality
        requestOptions.isNetworkAccessAllowed = true

        let imagePromise = Future<UIImage, Never> { promise in
            let manager = PHImageManager.default()

            manager.requestImage(for: asset,
                                 targetSize: PHImageManagerMaximumSize,
                                 contentMode: .aspectFill,
                                 options: requestOptions) { img, info  in
                                    guard let img = img else {
                                        if let isIniCloud = info?[PHImageResultIsInCloudKey] as? NSNumber,
                                            isIniCloud.boolValue == true {
                                            if let cloudImage = UIImage(systemName: "person.icloud.fill") {
                                                promise(.success(cloudImage))
                                            }
                                        }
                                        return
                                    }
                                    promise(.success(img))
            }
        }
        return imagePromise
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
