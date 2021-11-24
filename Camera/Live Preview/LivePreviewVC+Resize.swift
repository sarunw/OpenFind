//
//  LivePreviewVC+Resize.swift
//  Find
//
//  Created by Zheng on 11/22/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit

extension LivePreviewViewController {
    func updateViewportSize(safeViewFrame: CGRect) {
        guard let imageSize = imageSize else { return }
        
        let imageFitViewCenteredRect = calculateContentRect(imageSize: imageSize, containerSize: view.frame.size, aspectMode: .scaleAspectFit)
        let imageFillSafeCenteredRect = calculateContentRect(imageSize: imageFitViewCenteredRect.size, containerSize: safeViewFrame.size, aspectMode: .scaleAspectFill)
        
        /// only care about the fill rect - fills the safe area, with gap on left and right
        var imageFillSafeRect = imageFillSafeCenteredRect
        imageFillSafeRect.origin.y = safeViewFrame.origin.y
        
        self.imageFitViewSize = imageFitViewCenteredRect.size
        self.imageFillSafeRect = imageFillSafeRect
        
        updateAspectProgressTarget()
    }
    
    func updateAspectProgressTarget() {
        
        let halfImageHeight = self.imageFillSafeRect.height / 2
        
        let containerTopHalfHeight = self.imageFillSafeRect.midY
        let containerBottomHalfHeight = view.bounds.height - containerTopHalfHeight
        
        /// calculate the image's progress to the full view for both top and bottom
        let imageTopMultiplier = containerTopHalfHeight / halfImageHeight
        let imageBottomMultiplier = containerBottomHalfHeight / halfImageHeight
        let imageMultiplier = max(imageTopMultiplier, imageBottomMultiplier)
        
        imageFillSafeRect.setAsConstraints(
            left: previewFitViewLeftC,
            top: previewFitViewTopC,
            width: previewFitViewWidthC,
            height: previewFitViewHeightC
        )
        aspectProgressTarget = imageMultiplier
    }
    
    func calculateContentRect(imageSize: CGSize, containerSize: CGSize, aspectMode: UIView.ContentMode) -> CGRect {
        var contentRect = CGRect.zero
        
        let imageAspect = imageSize.height / imageSize.width
        let containerAspect = containerSize.height / containerSize.width
        if /// match width
            (imageAspect > containerAspect) && (aspectMode == .scaleAspectFill) || /// image extends top and bottom
            (imageAspect <= containerAspect) && (aspectMode == .scaleAspectFit) /// image has gap top and bottom
        {
            let newImageHeight = containerSize.width * imageAspect
            let newY = -(newImageHeight - containerSize.height) / 2
            contentRect = CGRect(x: 0, y: newY, width: containerSize.width, height: newImageHeight)
            
        } else if /// match height
            (imageAspect < containerAspect) && (aspectMode == .scaleAspectFill) || /// image extends left and right
            (imageAspect >= containerAspect) && (aspectMode == .scaleAspectFit) /// image has gaps left and right
        {
            
            let newImageWidth = containerSize.height * (1 / imageAspect) /// the width of the overflowing image
            let newX = -(newImageWidth - containerSize.width) / 2
            contentRect = CGRect(x: newX, y: 0, width: newImageWidth, height: containerSize.height)
        }
        
        return contentRect
    }
}