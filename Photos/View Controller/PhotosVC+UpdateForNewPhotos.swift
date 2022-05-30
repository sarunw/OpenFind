//
//  PhotosVC+UpdateForNewPhotos.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 3/17/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    
import UIKit

/**
 Update after new photos were added
 */

extension PhotosViewController {
    /// find after a new photo was scanned
    func findAfterQueuedSentencesUpdate(in photos: [Photo]) async {
        /// **Scenario 1:** searching inside a single photo in slides
        if let slidesState = model.slidesState {
            if self.searchNavigationProgressViewModel.percentageShowing {
                self.searchNavigationProgressViewModel.finishAutoProgress()
                    
                if
                    let photo = photos.first,
                    let index = slidesState.getSlidesPhotoIndex(photo: photo),
                    let slidesPhoto = slidesState.slidesPhotos[safe: index]
                {
                    if let viewController = slidesState.viewController?.getViewController(for: slidesPhoto.findPhoto.photo) {
                        slidesState.viewController?.findFromMetadata(in: slidesPhoto, viewController: viewController, animate: false)
                    }
                }
                    
                Find.prioritizedAction = nil
            }
            
            /// **Scenario 2:** searching inside results screen while scanning
        } else if let resultsState = model.resultsState {
            let realmModel = self.realmModel
            let stringToGradients = self.searchViewModel.stringToGradients
            
            let existingAllFindPhotos = resultsState.allFindPhotos
            let existingStarredFindPhotos = resultsState.starredFindPhotos
            let existingScreenshotsFindPhotos = resultsState.screenshotsFindPhotos
            
            let photosResultsInsertNewMode = Settings.Values.PhotosResultsInsertNewMode(rawValue: realmModel.photosResultsInsertNewMode)
            
            Task.detached {
                // TODO: Optimize
                let (
                    allFindPhotos, starredFindPhotos, screenshotsFindPhotos
                ) = Finding.findAndGetFindPhotos(
                    realmModel: realmModel,
                    from: photos,
                    stringToGradients: stringToGradients,
                    scope: .text
                )
                
                if
                    let photosResultsInsertNewMode = photosResultsInsertNewMode,
                    photosResultsInsertNewMode == .top
                {
                    await self.startApplyingResults(
                        allFindPhotos: FindPhoto.merge(allFindPhotos + existingAllFindPhotos),
                        starredFindPhotos: FindPhoto.merge(starredFindPhotos + existingStarredFindPhotos),
                        screenshotsFindPhotos: FindPhoto.merge(screenshotsFindPhotos + existingScreenshotsFindPhotos),
                        context: .justFindFromExistingDoNotScan
                    )
                } else {
                    await self.startApplyingResults(
                        allFindPhotos: (existingAllFindPhotos + allFindPhotos).uniqued(),
                        starredFindPhotos: (existingStarredFindPhotos + starredFindPhotos).uniqued(),
                        screenshotsFindPhotos: (existingScreenshotsFindPhotos + screenshotsFindPhotos).uniqued(),
                        context: .justFindFromExistingDoNotScan
                    )
                }
            }
        }
    }
}