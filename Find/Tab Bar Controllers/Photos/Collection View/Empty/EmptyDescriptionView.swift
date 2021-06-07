////
////  EmptyDescriptionView.swift
////  Find
////
////  Created by Zheng on 1/26/21.
////  Copyright © 2021 Andrew. All rights reserved.
////
//
//import UIKit
//
//class EmptyDescriptionView: UIView {
//    
//    var startTutorial: ((PhotoFilter) -> Void)?
//    
//    @IBOutlet var contentView: UIView!
//    
//    @IBOutlet weak var imageView: UIImageView!
//    @IBOutlet weak var headerLabel: LTMorphingLabel!
//    @IBOutlet weak var descriptionLabel: UILabel!
//    
//    var tutorialActive = false
//    @IBOutlet weak var showMeHowButton: UIButton!
//    @IBAction func showMeHowPressed(_ sender: Any) {
//        tutorialActive.toggle()
//        if tutorialActive {
//            showTutorial()
//        } else {
//            stopTutorial()
//        }
//    }
//    
//    var currentDisplayedFilter = PhotoFilter.all
//    
//    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        commonInit()
//    }
//    
//    required init?(coder: NSCoder) {
//        super.init(coder: coder)
//        commonInit()
//    }
//    
//    private func commonInit() {
//        Bundle.main.loadNibNamed("EmptyDescriptionView", owner: self, options: nil)
//        addSubview(contentView)
//        contentView.frame = self.bounds
//        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        
//        headerLabel.morphingEffect = .evaporate
//        headerLabel.accessibilityTraits = .header
//        
//        TipViews.resetToBeginning = { [weak self] in
//            guard let self = self else { return }
//            self.tutorialActive = false
//            self.makeTutorialButtonEnabled()
//        }
//    }
//    
//    func change(from previousFilter: PhotoFilter, to photoFilter: PhotoFilter) {
//        if currentDisplayedFilter != photoFilter {
//            let headerText: String
//            let descriptionText: String
//            var newImage: UIImage?
//            var flipFromRight = false
//            
//            switch photoFilter {
//            case .local:
//                headerText = NSLocalizedString("local", comment: "")
//                descriptionText = NSLocalizedString("emptyDesc-photosSavedFromFind", comment: "")
//                newImage = UIImage(named: "LocalPhotos")
//                flipFromRight = true
//                UIView.animate(withDuration: 0.2) {
//                    self.showMeHowButton.tintColor = UIColor(named: "100Blue")
//                }
//            case .starred:
//                headerText = NSLocalizedString("starred", comment: "")
//                descriptionText = NSLocalizedString("emptyDesc-starThePhotosYouView", comment: "")
//                newImage = UIImage(named: "StarredPhotos")
//                if previousFilter != .local {
//                    flipFromRight = true
//                }
//                UIView.animate(withDuration: 0.2) {
//                    self.showMeHowButton.tintColor = UIColor(named: "Gold")
//                }
//            case .cached:
//                headerText = NSLocalizedString("Cached", comment: "")
//                descriptionText = NSLocalizedString("resultsWillAppearInstantly", comment: "")
//                newImage = UIImage(named: "CachedPhotos")
//                if previousFilter == .all {
//                    flipFromRight = true
//                }
//                UIView.animate(withDuration: 0.2) {
//                    self.showMeHowButton.tintColor = UIColor(named: "100Blue")                
//                }
//            case .all:
//                headerText = ""
//                descriptionText = ""
//                break
//            }
//            
//            headerLabel.text = headerText
//            
//            descriptionLabel.fadeTransition(0.15)
//            descriptionLabel.text = descriptionText
//            
//            UIView.transition(with: imageView, duration: 0.3, options: flipFromRight ? .transitionFlipFromRight : .transitionFlipFromLeft) {
//                self.imageView.image = newImage
//            }
//            currentDisplayedFilter = photoFilter
//        }
//    }
//}
