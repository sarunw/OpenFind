//
//  PhotoFindVC+FindBarDelegate.swift
//  Find
//
//  Created by Zheng on 1/16/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit

extension PhotoFindViewController: FindBarDelegate {
    func pause(pause: Bool) {}
    
    func returnTerms(matchToColorsR: [String: [HighlightColor]]) {
        matchToColors = matchToColorsR
        if matchToColorsR.keys.count >= 1 {
            shouldAnnounceStatus = true /// set true now, so later on will announce prompt
            findFromCache()
        } else { /// no text entered
            changePromptToStarting(startingFilterState: photoFilterState, howManyPhotos: findPhotos.count, isAllPhotos: findingFromAllPhotos, announce: shouldAnnounceStatus)
            resultPhotos.removeAll()
            tableView.reloadData()
            currentFastFindProcess = nil
            progressView.alpha = 0
            tableView.alpha = 1
        }
    }
    
    func startedEditing(start: Bool) {}
    
    func pressedReturn() {
        continuePressed(dismissKeyboard: false)
    }
    
    func triedToEdit() {}
    
    func triedToEditWhilePaused() {}
    
    func pressedContinue() {
        if numberCurrentlyFindingFromCache == 0 {
            setPromptToHowManyFastFound(howMany: 0)
            fastFind()
        }
    }
}
