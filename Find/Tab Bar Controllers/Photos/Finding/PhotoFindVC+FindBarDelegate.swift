//
//  PhotoFindVC+FindBarDelegate.swift
//  Find
//
//  Created by Zheng on 1/16/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit

extension PhotoFindViewController: FindBarDelegate {
    func pause(pause: Bool) {
        print("Pause findbar")
    }
    
    func returnTerms(matchToColorsR: [String : [CGColor]]) {
        print("returnTerms findbar")
        
        self.matchToColors = matchToColorsR
        if matchToColorsR.keys.count >= 1 {
            findFromCache()
        } else { /// no text entered
            changePromptToStarting(startingFilter: currentFilter, howManyPhotos: findPhotos.count, isAllPhotos: findingFromAllPhotos)
            resultPhotos.removeAll()
            tableView.reloadData()
            currentFastFindProcess = nil
            self.progressView.alpha = 0
        }
        
        
    }
    
    func startedEditing(start: Bool) {
        print("startedEditing findbar")
    }
    
    func pressedReturn() {
        print("pressedReturn findbar------------")
        if numberCurrentlyFindingFromCache == 0 {
            setPromptToHowManyFastFound(howMany: 0)
            fastFind()
        }
    }
    
    func triedToEdit() {
        print("triedToEdit findbar")
    }
    
    func triedToEditWhilePaused() {
        print("ReturnSortedTerms triedToEditWhilePaused")
    }
    
}