//
//  ListsViewController+NavigationBar.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 1/8/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    

import UIKit







//struct AnimatableVisualEffectView: UIViewRepresentable {
//    @Binding var progress: CGFloat
//    @State var blurEffectView = BlurEffectView()
//    
//    func makeUIView(context: UIViewRepresentableContext<Self>) -> BlurEffectView {
//        NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: .main) { _ in
//            refresh()
//        }
//        return blurEffectView
//    }
//
//    func updateUIView(_ uiView: BlurEffectView, context: UIViewRepresentableContext<Self>) {
//        uiView.updateProgress(percentage: progress)
//    }
//    
//    /// re-make the blur after coming back from the home screen/app switcher
//    func refresh() {
//        blurEffectView.setupBlur()
//        blurEffectView.updateProgress(percentage: progress)
//    }
//}

class BlurEffectView: UIVisualEffectView {
    var animator: UIViewPropertyAnimator?
    
    override func didMoveToSuperview() {
        guard let superview = superview else { return }
        backgroundColor = .clear
        frame = superview.bounds
        setupBlur()
    }
    
    func setupBlur() {
        animator?.stopAnimation(true)
        animator?.finishAnimation(at: .start)
        animator = UIViewPropertyAnimator(duration: 1, curve: .linear)
        effect = UIBlurEffect(style: .systemUltraThinMaterialDark)

        animator?.addAnimations { [weak self] in
            self?.effect = UIBlurEffect(style: .systemThickMaterial)
        }
        animator?.fractionComplete = 0
    }
    
    func updateProgress(percentage: CGFloat) {
        animator?.fractionComplete = percentage
    }
    
    deinit {
        animator?.stopAnimation(true)
    }
}