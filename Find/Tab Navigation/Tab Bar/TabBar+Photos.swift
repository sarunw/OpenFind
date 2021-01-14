//
//  TabBar+Photos.swift
//  Find
//
//  Created by Zheng on 1/9/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit

enum PhotoSlideAction {
    case share
    case star
    case cache
    case delete
    case info
    
}
extension TabBarView {
    func showPhotoSelectionControls(show: Bool) {
        if show {
            controlsReferenceView.isUserInteractionEnabled = true
            stackView.isHidden = true
            controlsReferenceView.addSubview(photosControls)
            photosControls.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
        } else {
            controlsReferenceView.isUserInteractionEnabled = false
            stackView.isHidden = false
            photosControls.removeFromSuperview()
        }
        
    }
    func showPhotoSlideControls(show: Bool) {
        if show {
            controlsReferenceView.isUserInteractionEnabled = true
            controlsReferenceView.addSubview(photoSlideControls)
            photoSlideControls.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
            
            photoSlideControls.alpha = 0
            UIView.animate(withDuration: 0.3) {
                self.stackView.alpha = 0
                self.photoSlideControls.alpha = 1
            }
            photoSlideControls.isUserInteractionEnabled = true
            
        } else {
            controlsReferenceView.isUserInteractionEnabled = false

            UIView.animate(withDuration: 0.3) {
                self.stackView.alpha = 1
                self.photoSlideControls.alpha = 0
            } completion: { _ in
                self.photoSlideControls.removeFromSuperview()
            }
        }
        
    }
    func dimPhotoSlideControls(dim: Bool) {
        if dim {
            photoSlideControls.alpha = 0.5
            photoSlideControls.isUserInteractionEnabled = false
        } else {
            photoSlideControls.alpha = 1
            photoSlideControls.isUserInteractionEnabled = true
        }
    }
    func updateActions(action: ChangeActions) {
        switch action {
        case .shouldStar:
            let starImage = UIImage(systemName: "star")
            starButton.setImage(starImage, for: .normal)
        case .shouldNotStar:
            print("nop")
            let starFillImage = UIImage(systemName: "star.fill")
            starButton.setImage(starFillImage, for: .normal)
        case .shouldCache:
            let cacheText = "Cache"
            cacheButton.setTitle(cacheText, for: .normal)
        case .shouldNotCache:
            let cachedText = "Cached"
            cacheButton.setTitle(cachedText, for: .normal)
        }
    }
}