//
//  ViewController.swift
//  TabBarControllerTesting
//
//  Created by Zheng on 10/28/21.
//

import SwiftUI
import TabBarController
import Camera

class ViewController: UIViewController {

    lazy var photosViewController: PhotosViewController = {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let viewController = storyboard.instantiateViewController(withIdentifier: "PhotosViewController") as? PhotosViewController {
            viewController.getActiveToolbarViewModel = { [weak self] in
                guard let self = self else { return ToolbarViewModel() }
                return self.toolbarViewModel
            }
            return viewController
        }
        fatalError()
    }()
    lazy var camera: CameraController = {
        return Camera.Bridge.makeController()
    }()
    lazy var listsViewController: ListsViewController = {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let viewController = storyboard.instantiateViewController(withIdentifier: "ListsViewController") as? ListsViewController {
            return viewController
        }
        fatalError()
    }()
    
    var toolbarViewModel: ToolbarViewModel!
    lazy var tabController: TabBarController<Camera.CameraToolbarView, PhotosSelectionToolbarView, PhotosSelectionToolbarView, PhotosSelectionToolbarView> = {
        toolbarViewModel = ToolbarViewModel()
        
        
        photosViewController.activateSelectionToolbar = { [weak self] activate in
            guard let self = self else { return }
            if activate {
                withAnimation {
                    self.toolbarViewModel.toolbar = .photosSelection
                }
            } else {
                withAnimation {
                    self.toolbarViewModel.toolbar = .none
                }
            }
        }
        
        let tabController = Bridge.makeTabController(
            pageViewControllers: [photosViewController, camera.viewController, listsViewController],
            toolbarViewModel: toolbarViewModel,
            cameraToolbarView: camera.viewController.toolbar,
            photosSelectionToolbarView: photosViewController.selectionToolbar,
            photosDetailToolbarView: photosViewController.selectionToolbar,
            listsSelectionToolbarView: photosViewController.selectionToolbar
        )
        
        tabController.delegate = self
        
        self.addChild(tabController.viewController, in: self.view)
        
        return tabController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        _ = tabController
       
    }
}

extension ViewController: TabBarControllerDelegate {
    func willBeginNavigatingTo(tab: TabState) {
        switch tab {
        case .photos:
            photosViewController.willBecomeActive()
            camera.viewController.willBecomeInactive()
            listsViewController.willBecomeInactive()
        case .camera:
            photosViewController.willBecomeInactive()
            camera.viewController.willBecomeActive()
            listsViewController.willBecomeInactive()
        case .lists:
            photosViewController.willBecomeInactive()
            camera.viewController.willBecomeInactive()
            listsViewController.willBecomeActive()
        default: break
        }
    }
    
    func didFinishNavigatingTo(tab: TabState) {
        switch tab {
        case .photos:
            photosViewController.didBecomeActive()
            camera.viewController.didBecomeInactive()
            listsViewController.didBecomeInactive()
        case .camera:
            photosViewController.didBecomeInactive()
            camera.viewController.didBecomeActive()
            listsViewController.didBecomeInactive()
        case .lists:
            photosViewController.didBecomeInactive()
            camera.viewController.didBecomeInactive()
            listsViewController.didBecomeActive()
        default: break
        }
    }
}

extension UIViewController {
    func addChild(_ childViewController: UIViewController, in inView: UIView) {
        // Add Child View Controller
        addChild(childViewController)
        
        // Add Child View as Subview
        inView.insertSubview(childViewController.view, at: 0)
        
        // Configure Child View
        childViewController.view.frame = inView.bounds
        childViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // Notify Child View Controller
        childViewController.didMove(toParent: self)
    }
    func removeChild(_ childViewController: UIViewController) {
        // Notify Child View Controller
        childViewController.willMove(toParent: nil)

        // Remove Child View From Superview
        childViewController.view.removeFromSuperview()

        // Notify Child View Controller
        childViewController.removeFromParent()
    }
}

