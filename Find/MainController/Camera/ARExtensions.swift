//
//  ARExtensions.swift
//  Find
//
//  Created by Andrew on 10/25/19.
//  Copyright © 2019 Andrew. All rights reserved.
//

import UIKit
import ARKit

extension ViewController {
    func runImageTrackingSession(with trackingImages: Set<ARReferenceImage>,
                                         runOptions: ARSession.RunOptions = [.removeExistingAnchors, .resetTracking]) {
        let configuration = ARImageTrackingConfiguration()
        configuration.maximumNumberOfTrackedImages = 20
        configuration.trackingImages = trackingImages
        sceneView.session.run(configuration, options: runOptions)
        print("run image tracking session")
    }
    //MARK: focus renderer
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
        if let imageAnchor = anchor as? ARImageAnchor {
            print("asdla")
            let plane1 = SCNPlane(width: imageAnchor.referenceImage.physicalSize.width, height: imageAnchor.referenceImage.physicalSize.height)
            
            plane1.firstMaterial?.diffuse.contents = UIColor(white: 1.0, alpha: 0.3)
            plane1.cornerRadius = 0.005
            let planeNode1 = SCNNode(geometry: plane1)
                            planeNode1.eulerAngles.x = -.pi / 2
            node.addChildNode(planeNode1)
            detectedPlanes[planeNode1] = imageAnchor
            
        }
            return node
    }
    func getImage(node: SCNNode) {

        if firstTimeFocusHighlight == 0 || findingInNode == false {
            if let anchor = detectedPlanes[node] {
                if let corners = self.projection(from: anchor) {
                        if findingInNode == false {
                            DispatchQueue.global(qos: .background).async {
                                self.findInNode(points: corners.0, buffer: corners.1)
                            }
                        }
                    if firstTimeFocusHighlight == 0 {
                        firstTimeFocusHighlight += 1
                        var size = CGSize()
                        size.width = corners.0[2].x - corners.0[3].x
                        size.height = corners.0[1].y - corners.0[3].y
                        let shape = getRect(size: size)
                        let planeNode = SCNNode(geometry: shape)
                        planeNode.eulerAngles.z = -.pi / 2
                        blueNode.addChildNode(planeNode)
                        currentHighlightNode = planeNode
                        let action = SCNAction.scale(to: 1.1, duration: 0.2)
                        blueNode.geometry?.firstMaterial?.diffuse.contents = UIColor.white.withAlphaComponent(0.2)
                        planeNode.runAction(action, completionHandler: {
                            let action2 = SCNAction.scale(to: 1, duration: 0.3)
                            planeNode.runAction(action2)
                        })
                        
                    }
                }
            }
        }
        
    }
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
                if scanModeToggle == .focused {
                let results = sceneView.hitTest(crosshairPoint, options: nil)
                if let feature = results.first {
                    stopTagFindingInNode = false
                    focusTimer.suspend()
                    let planeNode = feature.node
                    blueNode = planeNode
                    isOnDetectedPlane = true
                    numberOfFocusTimes = 0
                    getImage(node: planeNode)
                } else {
                    numberOfFocusTimes += 1
        
                    stopTagFindingInNode = true
                    blueNode.geometry?.firstMaterial?.diffuse.contents = UIColor.white.withAlphaComponent(0.3)
        
                    let fadeOut = SCNAction.fadeOpacity(to: 0, duration: 0.2)
                         isOnDetectedPlane = false
                    currentHighlightNode.runAction(fadeOut, completionHandler: {
                        self.currentHighlightNode.removeFromParentNode()
                        self.firstTimeFocusHighlight = 0
        
                    })
                    if numberOfFocusTimes == 65 {
                        print("resume")
                        focusTimer.resume()
        
                    }
                }
                }
    }
    func projection(from anchor: ARImageAnchor) -> ([CGPoint], CVPixelBuffer)? {

        guard let camera = sceneView.session.currentFrame?.camera else {
        return nil
        }
        let refImg = anchor.referenceImage
        let transform = anchor.transform.transpose
        let size = deviceSize
        let width = Float(refImg.physicalSize.width / 2)
        let height = Float(refImg.physicalSize.height / 2)
        let pointsWorldSpace = [
            matrix_multiply(simd_float4([width, 0, -height, 1]), transform).vector_float3, // top right
            matrix_multiply(simd_float4([width, 0, height, 1]), transform).vector_float3, // bottom right
            matrix_multiply(simd_float4([-width, 0, -height, 1]), transform).vector_float3, // bottom left
            matrix_multiply(simd_float4([-width, 0, height, 1]), transform).vector_float3 // top left
        ]
        // Project 3D point to 2D space
        let pointsViewportSpace = pointsWorldSpace.map { (point) -> CGPoint in
            return camera.projectPoint(point,
                                       orientation: .portrait,
                                       viewportSize: size)
        }
            let array = pointsViewportSpace
            let buffer = sceneView.session.currentFrame?.capturedImage
            return (array, buffer) as? ([CGPoint], CVPixelBuffer)
        
    }
}
extension simd_float4 {
    var vector_float3: vector_float3 { return simd_float3([x, y, z]) }
}
