//
//  PhotosVC+Update.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 3/17/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    
import UIKit

extension PhotosViewController {
    /// find after a new photo was scanned
    func findAfterQueuedSentencesUpdate(in photos: [Photo]) {
        var insertedFindPhotos = [FindPhoto]()
        
        for photo in photos {
            guard let metadata = photo.metadata else { return }
            
            if let resultsState = model.resultsState {
                let (highlights, lines) = self.getHighlightsAndDescription(
                    from: metadata.sentences,
                    with: searchViewModel.stringToGradients
                )
                if highlights.count >= 1 {
                    let highlightsSet = FindPhoto.HighlightsSet(stringToGradients: self.searchViewModel.stringToGradients, highlights: highlights)
                    
                    if let index = resultsState.getFindPhotoIndex(photo: photo) {
                        model.resultsState?.findPhotos[index].highlightsSet = highlightsSet
                        model.resultsState?.findPhotos[index].associatedViewController?.highlightsViewModel.update(with: highlights, replace: true)
                    } else {
                        let thumbnail = self.model.photoToThumbnail[photo] ?? nil
                        let findPhoto = FindPhoto(
                            id: UUID(),
                            photo: photo,
                            thumbnail: thumbnail,
                            highlightsSet: highlightsSet,
                            descriptionText: description,
                            descriptionLines: lines
                        )
                        insertedFindPhotos.append(findPhoto)
                    }
                }
            }
                
            if let slidesState = model.slidesState {
                let highlights = metadata.sentences.getHighlights(stringToGradients: slidesSearchViewModel.stringToGradients)
                if highlights.count >= 1 {
                    let highlightsSet = FindPhoto.HighlightsSet(stringToGradients: self.slidesSearchViewModel.stringToGradients, highlights: highlights)
                    
                    if let index = slidesState.getFindPhotoIndex(photo: photo) {
                        model.slidesState?.findPhotos[index].highlightsSet = highlightsSet
                        model.slidesState?.findPhotos[index].associatedViewController?.highlightsViewModel.update(with: highlights, replace: true)
                    }
                }
                
                if self.searchNavigationProgressViewModel.percentageShowing {
                    self.searchNavigationProgressViewModel.finishAutoProgress()
                    Find.prioritizedAction = nil
                }
            }
        }
        
        
        self.model.resultsState?.findPhotos.insert(contentsOf: insertedFindPhotos, at: 0)
        self.model.slidesState?.findPhotos.insert(contentsOf: insertedFindPhotos, at: 0)
        self.updateResultsCollectionViews()
    }

    /// update the results collection view and the slides collection view
    func updateResultsCollectionViews() {
        self.updateResults(animate: true)
        self.model.slidesState?.viewController?.update(animate: false)
  
        if
            let slidesState = model.slidesState,
            let currentIndex = slidesState.getCurrentIndex()
        {
            print("index to scroll to: \(currentIndex)")
            self.model.slidesState?.viewController?.collectionView.scrollToItem(
                at: currentIndex.indexPath,
                at: .centeredHorizontally,
                animated: false
            )
        }
    }
}