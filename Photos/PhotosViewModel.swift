//
//  PhotosViewModel.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 2/12/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import Photos
import UIKit

class PhotosViewModel: ObservableObject {
    // MARK: Base collection view

    var realmModel: RealmModel
    
    /// all photos and assets
    var assets: PHFetchResult<PHAsset>?
    var photos = [Photo]()
    var displayedSections = [PhotosSection]() /// this is fed into the collection view
    
    /// when star/unstar
    var sortNeeded = false
    
    /// storage
    var starredSections = [PhotosSection]()
    var screenshotsSections = [PhotosSection]()
    var allSections = [PhotosSection]()

    /// store the cell images
    var photoToThumbnail = [Photo: UIImage?]()

    /// update the entire collection view, only called once at first. Set inside `PhotosVC+Listen`
    var reload: (() -> Void)?

    /// reload at a specific index path
    /// 1. Index path inside `collectionView`
    /// 2. Index inside `resultsCollectionView`
    /// 3. the photo metadata
    var reloadAt: ((IndexPath?, Int?, PhotoMetadata) -> Void)?

    /// PHAsset caching
    let imageManager = PHCachingImageManager()
    var previousPreheatRect = CGRect.zero

    // MARK: Filtering

    var sliderViewModel = SliderViewModel()

    // MARK: Slides / Results

    /// for use inside the slides' `willDisplay` cell - hide the container view if animating.
    var animatingSlides = false

    /// the slides' current status
    @Published var slidesState: PhotosSlidesState?

    /// the state of the results.
    var resultsState: PhotosResultsState?

    /// the date when the last results update occurred.
    var lastResultsUpdateTime: Date?

    /// about to present slides, update the slides search collection view to match the latest search view model
    /// Set this inside **PhotosController**
    /// Must call `replaceInPlace` first
    var updateSlidesSearchCollectionView: (() -> Void)?

    /// about to present slides, set the transition
    var transitionAnimatorsUpdated: ((PhotosViewController, PhotosSlidesViewController) -> Void)?

    /// the photo manager got an image, update the transition image view's image.
    var imageUpdatedWhenPresentingSlides: ((UIImage?) -> Void)?

    /// update the color/alpha with those of the specified fields
    var updateFieldOverrides: (([Field]) -> Void)?

    // MARK: Find from just-scanned photos

    /// sentences were recently added to these photos, but not applied to the main model yet.
    var photosWithQueuedSentences = [Photo]()

    /// if true, a sentences update is scheduled and should be applied ASAP.
    var updateState: PhotosSentencesUpdateState?

    /// set to false if finger is still touching
    var updateAllowed = true {
        didSet {
            if updateAllowed, updateState == .waitingForPermission {
                addQueuedSentencesToMetadatas()
            }
        }
    }

    /// sentences were applied! find inside them now and append to `resultsState` / `slidesState`.
    var photosWithQueuedSentencesAdded: (([Photo]) -> Void)?

    // MARK: Scanning

    var photosToScan = [Photo]() {
        didSet {
            totalPhotosCount = photos.filter { $0.metadata.map { !$0.isIgnored } ?? true }.count
            scannedPhotosCount = totalPhotosCount - photosToScan.count
        }
    }

    var scanningIconState: PhotosScanningIconState {
        if photosToScan.isEmpty {
            return .done
        }
        if scanningState == .dormant {
            return .paused
        }
        return .scanning
    }
    
    var scanningIconTapped: (() -> Void)? /// tapped icon in navigation bar
    var ignoredPhotosTapped: (() -> Void)?
    @Saved(Defaults.scanOnLaunch.0) var scanOnLaunch = Defaults.scanOnLaunch.1
    @Published var scanningState = ScanningState.dormant
    @Published var scannedPhotosCount = 0
    @Published var totalPhotosCount = 0 /// total where not ignored

    // MARK: Selection

    @Published var isSelecting = false
    @Published var selectedPhotos = [Photo]()

    // MARK: Ignored Photos

    var ignoredPhotos = [Photo]()
    @Published var ignoredPhotosIsSelecting = false
    @Published var ignoredPhotosSelectedPhotos = [Photo]()
    var ignoredPhotosUpdated: (() -> Void)? /// unignored photos, update collection view and selection state

    /// reload the collection view to make it empty
    var updateSearchCollectionView: (() -> Void)?
    var deleteSelected: (() -> Void)?

    init(realmModel: RealmModel) {
        self.realmModel = realmModel
        listenToRealm()
    }

    enum ScanningState {
        case dormant
        case scanningAllPhotos
    }
}
