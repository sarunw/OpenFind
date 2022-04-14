//
//  PhotosVM+Actions.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/10/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import SwiftUI

/**
 Star / Ignore
 */

extension PhotosViewModel {
    /// toggle star for a single photo. If multiple photos and one photo is unstarred, star all.
    func star(photos: [Photo]) {
        let photosStarred: [Bool] = photos.map {
            let starred = $0.metadata.map { $0.isStarred } ?? false
            return starred
        }

        let shouldStar = photosStarred.contains(false)

        for photo in photos {
            var newPhoto = photo
            if newPhoto.metadata != nil {
                newPhoto.metadata?.isStarred = shouldStar
                updatePhotoMetadata(photo: newPhoto, reloadCell: true)
            } else {
                let metadata = PhotoMetadata(
                    assetIdentifier: photo.asset.localIdentifier,
                    sentences: [],
                    dateScanned: nil,
                    isStarred: shouldStar,
                    isIgnored: false
                )
                newPhoto.metadata = metadata
                updatePhotoMetadata(photo: newPhoto, reloadCell: true)
            }
        }
    }

    func ignore(photos: [Photo]) {
        
        /// see which of the passed-in photos are ignored
        let photosIgnored: [Bool] = photos.map {
            let ignored = $0.isIgnored
            return ignored
        }

        let shouldIgnore = photosIgnored.contains(false)

        for photo in photos {
            var newPhoto = photo
            /// metadata exists, delete sentences
            if newPhoto.metadata != nil {
                newPhoto.metadata?.isIgnored = shouldIgnore
                newPhoto.metadata?.dateScanned = nil /// delete saved sentences anyway
                newPhoto.metadata?.sentences = []
                withAnimation {
                    updatePhotoMetadata(photo: newPhoto, reloadCell: true)
                }
            } else {
                let metadata = PhotoMetadata(
                    assetIdentifier: photo.asset.localIdentifier,
                    sentences: [],
                    dateScanned: nil,
                    isStarred: false,
                    isIgnored: shouldIgnore
                )
                newPhoto.metadata = metadata
                withAnimation {
                    updatePhotoMetadata(photo: newPhoto, reloadCell: true)
                }
            }
        }
    }

    // MARK: - Toolbar

    func configureToolbar(for photo: Photo) {
        if let metadata = photo.metadata {
            if metadata.isStarred {
                self.slidesState?.toolbarStarOn = true
                return
            }
        }
        self.slidesState?.toolbarStarOn = false
    }
}
