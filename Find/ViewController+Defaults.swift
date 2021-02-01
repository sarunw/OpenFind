//
//  ViewController+Defaults.swift
//  Find
//
//  Created by Zheng on 1/28/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit

extension ViewController {
    func readDefaults() {
        print("swipe? \(UserDefaults.standard.bool(forKey: "swipeToNavigateEnabled"))")
        longPressGestureRecognizer.isEnabled = UserDefaults.standard.bool(forKey: "swipeToNavigateEnabled")
        panGestureRecognizer.isEnabled = UserDefaults.standard.bool(forKey: "swipeToNavigateEnabled")
        
        DispatchQueue.main.async {
            self.camera.sortSearchTerms(removeExistingHighlights: false)
            for subView in self.camera.drawingView.subviews {
                subView.removeFromSuperview()
            }
            self.camera.drawHighlights(highlights: self.camera.currentComponents)
            
            self.photos.photoFindViewController.findBar.sortSearchTerms()
            self.photos.photoFindViewController.tableView?.reloadData()
        }
    }
    
    /// prevent swiping, then reset to defaults
    func temporaryPreventGestures(_ prevent: Bool) {
        if prevent {
            longPressGestureRecognizer.isEnabled = false
            panGestureRecognizer.isEnabled = false
        } else {
            if UserDefaults.standard.bool(forKey: "swipeToNavigateEnabled") {
                longPressGestureRecognizer.isEnabled = true
                panGestureRecognizer.isEnabled = true
            }
        }
    }
}
