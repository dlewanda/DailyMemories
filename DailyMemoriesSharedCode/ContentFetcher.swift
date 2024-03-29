//
//  ContentFetcher.swift
//  Daily Memories
//
//  Created by David Lewanda on 2/17/20.
//  Copyright © 2020 LewandaCode. All rights reserved.
//

import OSLog
import Photos
import Combine
import UIKit
import AVKit

public enum AssetError: Error {
    case videoIniCloud
    case noImageForToday
    case unknownError
}

public struct Asset: Identifiable {
    public let id = UUID()
    public let phAsset: PHAsset
}

public struct YearlyAssets: Identifiable {
    public var id = UUID()

    static var sectionHeaderFormat: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.usesGroupingSeparator = false
        return formatter
    }

    let year: Int
    public var assets: [Asset] = [Asset]()

    public var yearString: String {
        return Self.sectionHeaderFormat.string(from: NSNumber(value: year)) ?? "-----"
    }
}

public class ContentFetcher: ObservableObject {
    public static let shared = ContentFetcher()

    @Published public var authorizationStatus = PHAuthorizationStatus.notDetermined
    @Published public var yearlyAssets: [YearlyAssets] = [YearlyAssets]()
    private var cancellables = Set<AnyCancellable>()

    public func requestPhotoAccess() {
        requestPhotosAccessPromise()
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] authorizationStatus in
                self?.authorizationStatus = authorizationStatus
                if let strongSelf = self, strongSelf.authorizationStatus == .authorized {
                    strongSelf.yearlyAssets = strongSelf.fetchDailyAssets(for: Date())
                }
            })
            .store(in: &cancellables)
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
                Logger.logger(for: Self.Type.self)
                    .log("unknown authorization status")
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

        // initialize asset date with requested date
        var assetDate = date
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current

        let components = calendar.dateComponents([.year, .month, .day], from: date)
        let month = components.month ?? 0
        let day = components.day ?? 0
        var year = components.year ?? 0

        while assetDate >= oldestAssetDate {
            let todayAssets = fetchAssets(for: assetDate)

            if todayAssets.count > 0 {
                var yearlyAssets = YearlyAssets(year: year)

//                print("-----------")
                Logger.logger(for: Self.Type.self)
                    .log("\(assetDate) photo count: \(todayAssets.count)")
                todayAssets.enumerateObjects { (asset, index, stop) in
                    yearlyAssets.assets.append(Asset(phAsset: asset))
                }
                assets.append(yearlyAssets)
                //TODO: 👇🏼should be never be committed!
//                assets = [yearlyAssets]
//                print("-----------")
            }
            year -= 1
            assetDate = calendar.date(from: DateComponents(year:year, month: month, day: day, hour: 0, minute: 0, second: 0))!
        }

        return assets
    }

    public func refreshAssets() {
        yearlyAssets = fetchDailyAssets()
    }

    public func mostRecentAssetForThis(date: Date) -> PHFetchResult<PHAsset> {
        var assets = fetchAssets(for: date)
        var years = 1

        guard let oldestAsset = fetchOldestAsset(),
              let oldestAssetDate = oldestAsset.creationDate else {
            return assets
        }

        while assets.count == 0 {
            guard let nextDate = Calendar.current.date(byAdding: .year, value: -years, to: date),
                  nextDate > oldestAssetDate else {
                break
            }

            assets = fetchAssets(for: nextDate)
            years += 1
        }
        return assets
    }
}

// MARK: -
// MARK: Image
extension ContentFetcher {
    public func loadImage(asset: PHAsset,
                          quality: PHImageRequestOptionsDeliveryMode = .opportunistic,
                          size: CGSize = PHImageManagerMaximumSize,
                          progressHandler: PHAssetImageProgressHandler? = nil) -> Future<UIImage, Error> {
        let requestOptions = PHImageRequestOptions()
        requestOptions.deliveryMode = quality
        requestOptions.resizeMode = .exact
        requestOptions.isNetworkAccessAllowed = true
        if progressHandler != nil {
            requestOptions.progressHandler = progressHandler
        }

        let imagePromise = Future<UIImage, Error> { promise in
            let manager = PHCachingImageManager.default()

            if requestOptions.deliveryMode == .highQualityFormat {
                // debugging
                Logger.logger(for: Self.Type.self)
                    .log("Fetching asset with quality \(requestOptions.deliveryMode.rawValue)")
            }
            manager.requestImage(for: asset,
                                 targetSize: size,
                                 contentMode: .aspectFit,
                                 options: requestOptions) { img, info in
                if requestOptions.deliveryMode == .highQualityFormat {
                    Logger.logger(for: Self.Type.self)
                        .log("Fetched asset with quality \(requestOptions.deliveryMode.rawValue)")
                }
                guard let img = img else {
                    if let isIniCloud = info?[PHImageResultIsInCloudKey] as? NSNumber,
                       isIniCloud.boolValue == true {
                        if let cloudImage = UIImage(systemName: "person.icloud.fill") {
                            promise(.success(cloudImage))
                        }
                    } else {
                        promise(.failure(AssetError.unknownError))
                    }
                    return
                }
                promise(.success(img))
            }
        }
        return imagePromise
    }

    /// method to retrieve images using a reactive paradigm
    public func getImageFor(date: Date) -> AnyPublisher<(UIImage, Int), Error> {
        let assets = mostRecentAssetForThis(date: date)
        guard let firstAsset = assets.firstObject else {
            return Future<(UIImage, Int), Error> { promise in
                promise(.failure(AssetError.noImageForToday))
            }
            .eraseToAnyPublisher()
        }

        return loadImage(asset: firstAsset, quality: .opportunistic)
            .flatMap { image in
                return Future<(UIImage, Int), Error> { promise in
                    promise(.success((image, firstAsset.year)))
                }.eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    /// method to get image and return it in a callback for use in the widget implementation
    public func getImageFor(date: Date, completion: @escaping (UIImage?, Int) -> Void) {
        getImageFor(date: date)
            .receive(on: DispatchQueue.main)
            .sink { error in
                completion(nil, 0)
            } receiveValue: { (image, year) in
                completion(image, year)
            }
            .store(in: &cancellables)
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
                                        } else {
                                            promise(.failure(AssetError.unknownError))
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
                                            } else {
                                                promise(.failure(AssetError.unknownError))
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
