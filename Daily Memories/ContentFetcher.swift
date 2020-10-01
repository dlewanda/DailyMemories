//
//  ContentFetcher.swift
//  Daily Memories
//
//  Created by David Lewanda on 2/17/20.
//  Copyright © 2020 LewandaCode. All rights reserved.
//

import Photos
import Combine
import UIKit
import AVKit

enum AssetError: Error {
    case videoIniCloud
}

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

class ContentFetcher: ObservableObject {
    public static let shared = ContentFetcher()

    @Published var authorizationStatus = PHAuthorizationStatus.notDetermined
    @Published public var yearlyAssets: [YearlyAssets] = [YearlyAssets]()
    private var requestCancellable: Cancellable?

    public func requestPhotoAccess() {
        let requestFuture = requestPhotosAccessPromise()
        requestCancellable = requestFuture
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] authorizationStatus in
                self?.authorizationStatus = authorizationStatus
                if let strongSelf = self, strongSelf.authorizationStatus == .authorized {
                    strongSelf.yearlyAssets = strongSelf.fetchDailyAssets(for: Date())
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
            case .limited:
                fallthrough //presumably limited should work like authorized, just return less
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

    /// fetches all assets for a specific date
    public func fetchAssets(for date: Date) -> PHFetchResult<PHAsset> {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: date)!

        let todayAssetOptions = PHFetchOptions()
        todayAssetOptions.predicate = NSPredicate(format: "creationDate > %@ AND creationDate < %@",
                                                  startOfDay as NSDate,
                                                  endOfDay as NSDate)
        todayAssetOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]

        let todayAssets: PHFetchResult<PHAsset> = PHAsset.fetchAssets(with: todayAssetOptions)

        return todayAssets
    }

    /// fetches assets for the day specified going back over all available years
    private func fetchDailyAssets(for date: Date = Date()) -> [YearlyAssets] {
        
        var assets = [YearlyAssets]()

        guard let oldestAsset = fetchOldestAsset(), let oldestAssetDate = oldestAsset.creationDate else {
            return assets
        }

        var photoDate = date
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current

        let components = calendar.dateComponents([.year, .month, .day], from: date)
        let month = components.month ?? 0
        let day = components.day ?? 0
        var year = components.year ?? 0

        while photoDate >= oldestAssetDate {
            let todayAssets = fetchAssets(for: photoDate)

            if todayAssets.count > 0 {
                var yearlyAssets = YearlyAssets(year: year)

                print("-----------")
                print("\(photoDate) photo count: \(todayAssets.count)")
                todayAssets.enumerateObjects { (asset, index, stop) in
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

    public func refreshAssets() {
        yearlyAssets = fetchDailyAssets()
    }
}

// MARK: -
// MARK: Image
extension ContentFetcher {
    public func loadImage(asset: PHAsset,
                          quality: PHImageRequestOptionsDeliveryMode = .opportunistic,
                          size: CGSize = PHImageManagerMaximumSize,
                          progressHandler: PHAssetImageProgressHandler? = nil) -> Future<UIImage, Never> {
        let requestOptions = PHImageRequestOptions()
        requestOptions.deliveryMode = quality
        requestOptions.resizeMode = .exact
        requestOptions.isNetworkAccessAllowed = true
        if progressHandler != nil {
            requestOptions.progressHandler = progressHandler
        }

        let imagePromise = Future<UIImage, Never> { promise in
            let manager = PHCachingImageManager.default()

            manager.requestImage(for: asset,
                                 targetSize: size,
                                 contentMode: .aspectFit,
                                 options: requestOptions) { img, info in
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
// MARK: Video
extension ContentFetcher {
    public func loadVideo(asset: PHAsset) -> Future<AVAsset?, Error> {
        let requestOptions = PHVideoRequestOptions()
        requestOptions.isNetworkAccessAllowed = true

        let videoPromise = Future<AVAsset?, Error> { promise in
            let manager = PHCachingImageManager.default()


            manager.requestAVAsset(forVideo: asset,
                                   options: requestOptions,
                                   resultHandler: {(asset: AVAsset?, audioMix: AVAudioMix?, info: [AnyHashable : Any]?) in

                                    guard let asset = asset else {
                                        if let isIniCloud = info?[PHImageResultIsInCloudKey] as? NSNumber,
                                            isIniCloud.boolValue == true {
                                            promise(.failure(AssetError.videoIniCloud))
                                        }
                                        return
                                    }
                                    promise(.success(asset))
            })
        }
        return videoPromise
    }
}

// MARK: -
// MARK: Live Photo
extension ContentFetcher {
    public func loadLivePhoto(asset: PHAsset,
                              quality: PHImageRequestOptionsDeliveryMode = .opportunistic,
                              size: CGSize = PHImageManagerMaximumSize,
                              progressHandler: PHAssetImageProgressHandler? = nil) -> Future<PHLivePhoto?, Error> {
        let requestOptions = PHLivePhotoRequestOptions()
        requestOptions.deliveryMode = quality
        requestOptions.isNetworkAccessAllowed = true
        if progressHandler != nil {
            requestOptions.progressHandler = progressHandler
        }
        let livePhotoPromise = Future<PHLivePhoto?, Error> { promise in
            let manager = PHCachingImageManager.default()

            manager.requestLivePhoto(for: asset,
                                     targetSize: size,
                                     contentMode: .aspectFit,
                                     options: requestOptions) { img, info in
                                        guard let img = img else {
                                            if let isIniCloud = info?[PHImageResultIsInCloudKey] as? NSNumber,
                                                isIniCloud.boolValue == true {
                                                promise(.failure(AssetError.videoIniCloud))
                                            }
                                            return
                                        }
                                        promise(.success(img))
            }
        }

        return livePhotoPromise
    }
}

// MARK: -
// MARK: Test Functions
extension ContentFetcher {
    public func fetchTestAssets() -> [YearlyAssets] {
        guard let oldestAssetDate = fetchOldestAsset()?.creationDate else {
            return [YearlyAssets]()
        }

        return fetchDailyAssets(for: oldestAssetDate)
    }

    public func fetchTestYearlyAssets() -> YearlyAssets {
        return fetchTestAssets().first ?? YearlyAssets(year: 2020)
    }

    public func fetchTestAsset() -> PHAsset {
        return fetchOldestAsset() ?? PHAsset()
    }
}
