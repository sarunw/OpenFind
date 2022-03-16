//
//  ListsVC+FlowLayout.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 1/21/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    
import UIKit

extension ListsViewController {
    func createFlowLayout() -> ListsCollectionFlowLayout {
        let flowLayout = ListsCollectionFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.getSections = { [weak self] in
            guard let self = self else { return [] }
            let indices = Array(self.model.displayedLists.indices)
            let section = Section(index: 0, indices: indices)
            return [section]
        }
//        flowLayout.getIndices = { [weak self] in
//            guard let self = self else { return [] }
//            let indices = Array(self.model.displayedLists.indices)
//            return indices
//        }
        flowLayout.getSizeForIndexWithWidth = { [weak self] listIndex, availableWidth in
            guard let self = self else { return .zero }
            return self.getCellSize(listIndex: listIndex, availableWidth: availableWidth)
        }
        
        collectionView.setCollectionViewLayout(flowLayout, animated: false)
        return flowLayout
    }
    
    func getCellSize(listIndex: Int, availableWidth: CGFloat) -> CGSize {
        let list = self.model.displayedLists[listIndex].list
        let c = ListsCellConstants.self
        
        let headerHeight = c.headerTitleFont.lineHeight
            + c.headerEdgeInsets.top
            + c.headerEdgeInsets.bottom
        
        let contentWidth = availableWidth
            - c.contentEdgeInsets.left
            - c.contentEdgeInsets.right
        
        /// relative to content
        var offset = CGSize.zero
        var chipFrames = [ListFrame.ChipFrame]()
        var numberOfLines = 1
        
        /// return true if add word chip was added
        func addWordsLeftChipIfNecessary(currentIndex: Int, currentFrame: CGRect) -> Bool {
            guard numberOfLines == c.maxNumberOfChipLines else { return false }
            
            var nextWordWidth = CGFloat(0)
            if let nextWord = list.words[safe: currentIndex + 1] {
                let nextWordSize = c.chipFont.sizeOfString(nextWord)
                nextWordWidth = nextWordSize.width + c.chipSpacing
            }
            
            let wordsLeftAfterCurrent = list.words.count - currentIndex
            let wordsLeftText = "+\(wordsLeftAfterCurrent)"
            let wordsLeftTextSize = c.chipFont.sizeOfString(wordsLeftText)
            let combinedWidth = currentFrame.maxX + nextWordWidth + c.chipSpacing + wordsLeftTextSize.width
            
            if combinedWidth > contentWidth {
                let wordsLeftFrame = CGRect(
                    x: currentFrame.origin.x,
                    y: currentFrame.origin.y,
                    width: wordsLeftTextSize.width + c.chipEdgeInsets.left + c.chipEdgeInsets.right,
                    height: wordsLeftTextSize.height + c.chipEdgeInsets.top + c.chipEdgeInsets.bottom
                )
                let wordsLeftChipFrame = ListFrame.ChipFrame(
                    frame: wordsLeftFrame,
                    string: wordsLeftText,
                    chipType: .wordsLeft
                )
                chipFrames.append(wordsLeftChipFrame)
                return true
            }
            return false
        }
        
        if list.containsWords {
            for index in list.words.indices {
                let word = list.words[index]
                let size = c.chipFont.sizeOfString(word)
            
                let frame = CGRect(
                    x: offset.width,
                    y: offset.height,
                    width: size.width + c.chipEdgeInsets.left + c.chipEdgeInsets.right,
                    height: size.height + c.chipEdgeInsets.top + c.chipEdgeInsets.bottom
                )
            
                /// check if there's still space for the `+5` even after the frame AND the next word
                guard !addWordsLeftChipIfNecessary(currentIndex: index, currentFrame: frame) else {
                    break
                }
            
                if frame.maxX <= contentWidth {
                    let chipFrame = ListFrame.ChipFrame(
                        frame: frame,
                        string: word
                    )
                    chipFrames.append(chipFrame)
                    offset.width += frame.width + c.chipSpacing
                
                    /// try adding another line if not enough space
                } else if numberOfLines < c.maxNumberOfChipLines {
                    let updatedFrame = CGRect(
                        x: 0,
                        y: frame.height + c.chipSpacing,
                        width: frame.width,
                        height: frame.height
                    )
                
                    if !addWordsLeftChipIfNecessary(currentIndex: index, currentFrame: updatedFrame) {
                        let chipFrame = ListFrame.ChipFrame(
                            frame: updatedFrame,
                            string: word
                        )
                        chipFrames.append(chipFrame)
                        offset.width = frame.width + c.chipSpacing /// is the first chip in the new line
                        offset.height += updatedFrame.origin.y
                        numberOfLines += 1
                    } else {
                        break
                    }
                }
            }
        } else {
            let frame = CGRect(
                x: offset.width,
                y: offset.height,
                width: contentWidth,
                height: c.chipFont.lineHeight + c.chipEdgeInsets.top + c.chipEdgeInsets.bottom
            )
            let chipFrame = ListFrame.ChipFrame(
                frame: frame,
                string: "Add Words",
                chipType: .addWords
            )
            chipFrames.append(chipFrame)
        }
        
        let chipContainerHeight = offset.height + (chipFrames.last?.frame.height ?? 0)
        let containerHeight = chipContainerHeight
            + c.contentEdgeInsets.top
            + c.contentEdgeInsets.bottom
        
        let height = headerHeight + containerHeight
        model.displayedLists[listIndex].frame.chipFrames = chipFrames
        
        let cellSize = CGSize(width: availableWidth, height: height)
        return cellSize
    }
}
