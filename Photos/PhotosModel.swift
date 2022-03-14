//
//  PhotosModel.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 2/14/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import Photos
import UIKit

struct PhotosSlidesState {
    var viewController: PhotosSlidesViewController?
    var findPhotos: [FindPhoto]
    var startingFindPhoto: FindPhoto
    var currentIndex: Int?
    var isFullScreen = false /// hide the bars

    /// get from `findPhotos`
    func getFindPhotoIndex(findPhoto: FindPhoto) -> Int? {
        return getFindPhotoIndex(photo: findPhoto.photo)
    }
    
    /// get from `findPhotos`
    func getFindPhotoIndex(photo: Photo) -> Int? {
        if let firstIndex = findPhotos.firstIndex(where: { $0.photo == photo }) {
            return firstIndex
        }
        return nil
    }
    
    func getCurrentFindPhotoAndIndex() -> (FindPhoto, Int)? {
        if let currentIndex = currentIndex {
            if let findPhoto = findPhotos[safe: currentIndex] {
                return (findPhoto, currentIndex)
            }
        }
        return nil
    }
    
    /// for the current image
    var toolbarStarOn = false
    var toolbarInformationOn = false
}

struct PhotosResultsState {
    var findPhotos: [FindPhoto]

    /// get from `findPhotos`
    func getFindPhotoIndex(findPhoto: FindPhoto) -> Int? {
        return getFindPhotoIndex(photo: findPhoto.photo)
    }
    
    /// get from `findPhotos`
    func getFindPhotoIndex(photo: Photo) -> Int? {
        if let firstIndex = findPhotos.firstIndex(where: { $0.photo == photo }) {
            return firstIndex
        }
        return nil
    }
}

/// a photo that contains results to display (in the form of highlights)
struct FindPhoto: Hashable {
    var photo: Photo
    var thumbnail: UIImage?
    var fullImage: UIImage?
    var associatedViewController: PhotosSlidesItemViewController?

    /// results
    var highlights: Set<Highlight>?
    var descriptionText = ""
    var descriptionLines = [Line]()
    
    func getResultsText() -> String {
        if let highlights = highlights {
            switch highlights.count {
            case 0:
                return "No Results"
            case 1:
                return "1 Result"
            default:
                return "\(highlights.count) Results"
            }
        } else {
            return "No Results"
        }
    }

    struct Line: Hashable {
        var string: String
        var lineHighlights: Set<LineHighlight>? /// the frames of these highlights will be relative to the result cell

        struct LineHighlight: Hashable {
            var string: String
            /**
             from the start index to the end index

                Example: "Safari" - searching for "a"
                    1..<2
                    3..<4
             */
            var rangeInSentence: Range<Int>
            var colors: [UIColor]
            var alpha: CGFloat
        }
    }
}

extension FindPhoto {
    func dateString() -> String {
        if let string = photo.asset.creationDate?.convertDateToReadableString() {
            return string
        } else {
            return "2022"
        }
    }

    func resultsString() -> String {
        let string: String
        let count = highlights?.count ?? 0
        if count == 1 {
            string = "\(count) Result"
        } else {
            string = "\(count) Results"
        }
        return string
    }
}

struct PhotosSection: Hashable {
    var title: String
    var categorization: Categorization
    var photos = [Photo]()

    func hash(into hasher: inout Hasher) {
        hasher.combine(categorization)
    }

    static func == (lhs: PhotosSection, rhs: PhotosSection) -> Bool {
        lhs.categorization == rhs.categorization
    }

    enum Categorization: Equatable, Hashable {
        case date(year: Int, month: Int, day: Int)

        func getTitle() -> String {
            switch self {
            case .date(let year, let month, let day):
                let dateComponents = DateComponents(year: year, month: month, day: day)
                if let date = Calendar.current.date(from: dateComponents) {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "MMM d, yyyy"
                    let string = formatter.string(from: date)
                    return string
                }
            }

            return ""
        }
    }
}

extension PHAsset {
    func getDateCreatedCategorization() -> PhotosSection.Categorization? {
        if
            let components = creationDate?.get(.year, .month, .day),
            let year = components.year, let month = components.month, let day = components.day
        {
            let categorization = PhotosSection.Categorization.date(year: year, month: month, day: day)
            return categorization
        }
        return nil
    }
}
