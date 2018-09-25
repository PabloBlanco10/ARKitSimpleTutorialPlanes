//
//  ViewController.swift
//  ARKitTutorialPlanes
//
//  Created by Pablo Blanco Peris on 24/9/18.
//  Copyright © 2018 Pablo Blanco Peris. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        
        // Create a new scene
        //        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        
        // Set the scene to the view
        //        sceneView.scene = scene
        
        sceneView.autoenablesDefaultLighting = true
        
        //add tap gesture to addItem in the plane
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped))
        sceneView.addGestureRecognizer(tapGestureRecognizer)
        
        //add rotation gesture to items
        let rotationGesture = UIRotationGestureRecognizer(target: self, action: #selector(rotateModel))
        sceneView.addGestureRecognizer(rotationGesture)
        
        //add zoom gesture to items
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(pinch))
        sceneView.addGestureRecognizer(pinchGesture)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    //tap gesture to add object to the plane
    @objc
    fileprivate func tapped(sender: UITapGestureRecognizer){
        let sceneView = sender.view as! ARSCNView
        let tapLocation = sender.location(in: sceneView)
        
        let hitTest = sceneView.hitTest(tapLocation, types: .existingPlaneUsingExtent)
        if !hitTest.isEmpty {
            self.addItem(hitTestResult: hitTest.first!)
        }
    }
    
    
    //add item to the scene
    fileprivate func addItem(hitTestResult: ARHitTestResult){
        //object node
        let scene = SCNScene(named: "art.scnassets/cup.scn")
        let node = (scene?.rootNode)!
        node.name = "cup"
        
        //get translation position (third column) of real world
        let transform = hitTestResult.worldTransform
        let thirdColumn = transform.columns.3
        
        node.position = SCNVector3(thirdColumn.x, thirdColumn.y + 0.1, thirdColumn.z)
        
        //add node
        self.sceneView.scene.rootNode.addChildNode(node)
        debugPrint("___Node added")
    }
    
    private var originalRotation: SCNVector3?
    
    //rotate gesture to the scene
    @objc
    fileprivate func rotateModel(gesture: UIRotationGestureRecognizer){
        let location = gesture.location(in: sceneView)
        
        guard let node = sceneView.hitTest(location, options: nil).first?.node else { return }
        
        //check if node is cup to rotate it
        //disable plane rotation
        if node.name == "cup" {
            switch gesture.state {
            case .began:
                originalRotation = node.eulerAngles
            case .changed:
                guard var originalRotation = originalRotation else { return }
                originalRotation.y -= Float(gesture.rotation)
                node.eulerAngles = originalRotation
            default:
                originalRotation = nil
            }
        }
    }
    
    
    //pinch recognizer to make zoom and make objects bigger
    @objc
    fileprivate func pinch(sender: UIPinchGestureRecognizer){
        let sceneView = sender.view as! ARSCNView
        let pinchLocation = sender.location(in: sceneView)
        let hitTest = sceneView.hitTest(pinchLocation)
        
        if !hitTest.isEmpty {
            let results = hitTest.first!
            let node = results.node
            let pinchAction = SCNAction.scale(by: sender.scale, duration: 0)
            debugPrint(sender.scale)
            node.runAction(pinchAction)
            sender.scale = 1.0
        }
    }
    
    
    // MARK: - ARSCNViewDelegate
    
    /*
     // Override to create and configure nodes for anchors added to the view's session.
     func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
     let node = SCNNode()
     
     return node
     }
     */
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    //detect planes
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        debugPrint("_ plane detected!!!")
        
        guard let planeAnchor = anchor as? ARPlaneAnchor
            else {return}
        
        let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
        
        plane.firstMaterial?.diffuse.contents = UIColor.red
        
        let planeNode = SCNNode(geometry: plane)
        
        planeNode.position = SCNVector3(CGFloat(planeAnchor.extent.x), CGFloat(planeAnchor.extent.y), CGFloat(planeAnchor.extent.y))
        
        planeNode.eulerAngles.x = -.pi/2
        node.addChildNode(planeNode)
    }
    
    //update planes
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        
        debugPrint("_ plane updated!!!")

        guard let planeAnchor = anchor as? ARPlaneAnchor,
            let planeNode = node.childNodes.first,
            let plane = planeNode.geometry as? SCNPlane
            else {return}
        
        plane.width = CGFloat(planeAnchor.extent.x)
        plane.height = CGFloat(planeAnchor.extent.z)
        
        planeNode.position = SCNVector3(CGFloat(planeAnchor.center.x),
                                        CGFloat(planeAnchor.center.y),
                                        CGFloat(planeAnchor.center.z))
    }
    
}
