//
//  CameraVC+Find.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 12/30/21.
//  Copyright © 2021 A. Zheng. All rights reserved.
//

import AVFoundation
import UIKit

extension CameraViewController {
    /// use fast mode
    func findAndAddHighlights(pixelBuffer: CVPixelBuffer) async {
        var options = FindOptions()
        options.orientation = .right
        options.level = .fast
        options.customWords = searchViewModel.customWords

        /// `nil` if was finding before
        let request = await Find.find(in: .pixelBuffer(pixelBuffer), options: options, action: .camera, wait: false)
        let sentences = Find.getFastSentences(from: request)
        let highlights = sentences.getHighlights(stringToGradients: searchViewModel.stringToGradients)

        DispatchQueue.main.async {
            self.highlightsViewModel.update(with: highlights, replace: false)
            self.createLivePreviewEvent(sentences: sentences, highlights: highlights)
            self.checkEvents()
        }
    }

    /// use accurate mode and wait
    func findAndAddHighlights(image: CGImage, replace: Bool = false, wait: Bool) async -> [Sentence] {
        var options = FindOptions()
        options.orientation = .up
        options.level = .accurate
        options.customWords = searchViewModel.customWords

        let request = await Find.find(in: .cgImage(image), options: options, action: .camera, wait: true)
        let sentences = Find.getSentences(from: request)
        let highlights = sentences.getHighlights(stringToGradients: searchViewModel.stringToGradients)
        DispatchQueue.main.async {
            self.highlightsViewModel.update(with: highlights, replace: replace)
        }
        return sentences
    }
}
