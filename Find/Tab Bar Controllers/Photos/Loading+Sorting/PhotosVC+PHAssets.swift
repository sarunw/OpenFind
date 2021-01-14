//
//  PhotosVC+PHAssets.swift
//  Find
//
//  Created by Zheng on 1/4/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit
import Photos
import SnapKit
import RealmSwift

extension PhotosViewController {
    func fetchAssets() {
        let status: PHAuthorizationStatus
        if #available(iOS 14, *) {
            status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        } else {
            status = PHPhotoLibrary.authorizationStatus()
        }
        
        var permissionAction = PermissionAction.notDetermined
        switch status {
        case .notDetermined:
            permissionAction = .notDetermined
        case .restricted:
            permissionAction = .restricted
        case .denied:
            permissionAction = .goToSettings
        case .authorized:
            permissionAction = .allowed
        case .limited:
            permissionAction = .allowed
        @unknown default:
            print("unknown default")
        }
        
        if permissionAction != .allowed {
            showPermissionView(action: permissionAction)
        } else {
            let fetchOptions = PHFetchOptions()
            fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            allPhotos = PHAsset.fetchAssets(with: .image, options: fetchOptions)
            
            if let photos = allPhotos {
                
                var totalMonths = [Month]()
                var mutableMonths = [MutableMonth]()
                
//                var unmanagedObjects = [HistoryModel]()
//                if let photoObjects = self.photoObjects {
//                    for object in photoObjects {
//                        let unmanagedObject = HistoryModel(value: object)
//                        unmanagedObjects.append(unmanagedObject)
//                    }
//                }
                var editableModels = [EditableHistoryModel]()
                if let photoObjects = self.photoObjects {
                    for object in photoObjects {
                        let editableModel = EditableHistoryModel()
                        editableModel.assetIdentifier = object.assetIdentifier
                        editableModel.isTakenLocally = object.isTakenLocally
                        editableModel.isHearted = object.isHearted
                        editableModel.isDeepSearched = object.isDeepSearched
//                        editableModel. = object.assetIdentifier
                        
                        for content in object.contents {
                            let editableContent = EditableSingleHistoryContent()
                            editableContent.text = content.text
                            editableContent.height = CGFloat(content.height)
                            editableContent.width = CGFloat(content.width)
                            editableContent.x = CGFloat(content.x)
                            editableContent.y = CGFloat(content.y)
                            editableModel.contents.append(editableContent)
                        }
                        
                        editableModels.append(editableModel)
//                        let unmanagedObject = HistoryModel(value: object)
//                        unmanagedObjects.append(unmanagedObject)
                    }
                }
                
                DispatchQueue.global(qos: .userInitiated).async {
                    photos.enumerateObjects { (asset, index, stop) in
                        
                        var matchingRealmPhoto: EditableHistoryModel?
                        
                        for object in editableModels {
                            if object.assetIdentifier == asset.localIdentifier {
                                matchingRealmPhoto = object
                                break
                            }
                        }
                        
                        let findPhoto = FindPhoto()
                        if let matchingPhoto = matchingRealmPhoto {
                            findPhoto.editableModel = matchingPhoto
                        }
                        findPhoto.asset = asset
                        
                        if let photoDateCreated = asset.creationDate {
                            let sameMonths = mutableMonths.filter( { $0.monthDate.isEqual(to: photoDateCreated, toGranularity: .month) })
                            if let firstOfSameMonth = sameMonths.first {
                                firstOfSameMonth.photos.append(findPhoto)
                            } else {
                                let newMonth = MutableMonth()
                                newMonth.monthDate = photoDateCreated
                                newMonth.photos.append(findPhoto)
                                mutableMonths.append(newMonth)
                            }
                        }
                    }
                    DispatchQueue.main.async {
                        var allPhotosToDisplay = [FindPhoto]()
                        for mutableMonth in mutableMonths {
                            for photo in mutableMonth.photos {
                                allPhotosToDisplay.append(photo)
                            }
                            let realMonth = Month(monthDate: mutableMonth.monthDate, photos: mutableMonth.photos)
                            totalMonths.append(realMonth)
                        }

                        self.allMonths = totalMonths
                        self.monthsToDisplay = totalMonths
                        self.allPhotosToDisplay = allPhotosToDisplay
                        self.applySnapshot(animatingDifferences: false)
                        self.fadeCollectionView(false, instantly: false)
                    }
                }
                print("Done")
            }
        }
    }
    
    func fadeCollectionView(_ shouldFade: Bool, instantly: Bool) {
        let block: (() -> Void)
        var completion: (() -> Void)?
        
        if shouldFade {
            block = {
                self.collectionView.alpha = 0
                self.segmentedSlider.alpha = 0
            }
        } else {
            block = {
                self.collectionView.alpha = 1
                self.segmentedSlider.alpha = 1
                self.activityIndicator?.alpha = 0
            }
            completion = {
                self.activityIndicator?.stopAnimating()
            }
        }
        if instantly {
            block()
            completion?()
        } else {
            UIView.animate(withDuration: 0.6, animations: block) { _ in
                completion?()
            }
        }
    }
    
    func showPermissionView(action: PermissionAction) {
        
        collectionView.alpha = 0
        
        let permissionView = PhotoPermissionView()
        permissionView.permissionAction = action
        view.addSubview(permissionView)
        permissionView.snp.makeConstraints { (make) in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        permissionView.allowed = { [weak self] fullAccess in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.5, animations: {
                    permissionView.alpha = 0
                    self.collectionView.alpha = 1
                }) { _ in
                    permissionView.removeFromSuperview()
                }
                self.hasFullAccess = fullAccess
                self.fetchAssets()
            }
            
        }
    }
    
}
