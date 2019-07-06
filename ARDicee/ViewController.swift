//
//  ViewController.swift
//  ARDicee
//
//  Created by Khaled Bohout on 6/23/19.
//  Copyright © 2019 Khaled Bohout. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    var diceArray = [SCNNode]()
    
    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        // Set the view's delegate
        sceneView.delegate = self
        
        sceneView.autoenablesDefaultLighting = true
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
    
    //MARK: - Dice Rendering Methods
    
    override func touchesBegan(_ touches: Set<UITouch>,with event: UIEvent?) {
            
            if let touch = touches.first {
                let touchLocation = touch.location(in: sceneView)
                
                let result = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
                
                if let hitResult = result.first {
                    
                    addDice(at: hitResult)
                }
            }
            
        }
    
    func addDice(at location: ARHitTestResult) {
        
        // Create a new scene
        let dicescene = SCNScene(named: "art.scnassets/diceCollada.scn")!
        
        if let dicenode = dicescene.rootNode.childNode(withName: "Dice", recursively: true){
            
            dicenode.position = SCNVector3(location.worldTransform.columns.3.x,
                                           location.worldTransform.columns.3.y + dicenode.boundingSphere.radius,
                                           location.worldTransform.columns.3.z)
            
            diceArray.append(dicenode)
            
            sceneView.scene.rootNode.addChildNode(dicenode)
            
            roll(dice: dicenode)
        }
    }
    
    func roll(dice: SCNNode) {
        
        let randomX = Float(arc4random_uniform(4) + 1) * (Float.pi/2)
        
        let randomZ = Float(arc4random_uniform(4) + 1) * (Float.pi/2)
        
        dice.runAction(SCNAction.rotateBy(x: CGFloat(randomX * 5), y: 0, z: CGFloat(randomZ * 5), duration: 0.5))
    }
        
        func rollAll() {
            
            if !diceArray.isEmpty {
                
                for dice in diceArray {
                    
                    roll(dice: dice)
                }
            }
        }
    
    @IBAction func rollAgain(_ sender: UIBarButtonItem) {
        
        rollAll()
    }
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        
        rollAll()
    }
    
    @IBAction func removeAllDices(_ sender: UIBarButtonItem) {
        
        if !diceArray.isEmpty {
            for dice in diceArray {
                dice.removeFromParentNode()
            }
        }
    }
    
    //MARK: - ARSCNViewDelegateMethods
    
        func renderer(_ renderer: SCNSceneRenderer,didAdd node: SCNNode,for anchor: ARAnchor) {
            
            guard let planeAnchor = anchor as? ARPlaneAnchor else {return}

            let planeNode = creatPlane(with: planeAnchor)
            
            node.addChildNode(planeNode)
            
        }
    
    //MARK: - plane Rendering Methods
    
    func creatPlane(with planeAnchor: ARPlaneAnchor) -> SCNNode {
        
        let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
        
        let planeNode = SCNNode()
        
        planeNode.position = SCNVector3(planeAnchor.center.x,0, planeAnchor.center.z)
        
        planeNode.transform = SCNMatrix4MakeRotation(-Float.pi/2, 1, 0, 0)
        
        let gridMaterial = SCNMaterial()
        
        gridMaterial.diffuse.contents = UIImage(named: "art.scnassets/grid.png")
        
        plane.materials = [gridMaterial]
        
        planeNode.geometry = plane
        
        return planeNode
    }
}

