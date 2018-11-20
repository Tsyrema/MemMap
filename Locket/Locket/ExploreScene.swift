//
//  ExploreScene.swift
//  Locket
//
//  

import ARKit
import UIKit
import FirebaseDatabase

protocol DisplayPhotoDelegate {
    func displayPhoto (shouldDisplay: Bool)
}

class ExploreScene: SKScene {
    
    var photoDelegate: DisplayPhotoDelegate?
    var photoData = [String]()
    var ref:DatabaseReference!
    var databaseHandle:DatabaseHandle!
    
    var sceneView: ARSKView {
        return view as! ARSKView
    }
    
    var isWorldSetUp = false
    
    var image = UIImage()
    
    
    // Adding a picture
    private func setUpWorld() {
        //check whether the session has an initialized currentFrame
        guard let currentFrame = sceneView.session.currentFrame
            else { return }
        // create a four-dimensional identity matrix. Rotation and scaling use the first three columns
        var translation = matrix_identity_float4x4
        translation.columns.3.z = -0.3
        // ARKit will place the anchor at the correct position in 3D space relative to the camera
        let transform = currentFrame.camera.transform * translation
        //add an anchor to the session
        let anchor = ARAnchor(transform: transform)
        sceneView.session.add(anchor: anchor)
        
        isWorldSetUp = true
    }
    
    
    
    // this is called every frame
    override func update(_ currentTime: TimeInterval) {
        if !isWorldSetUp {
            setUpWorld()
        }
        // Light Estimation. If it's dark add light
        // 1
        guard let currentFrame = sceneView.session.currentFrame,
            let lightEstimate = currentFrame.lightEstimate else {
                return
        }
        
        // 2
        let neutralIntensity: CGFloat = 1000
        let ambientIntensity = min(lightEstimate.ambientIntensity,
                                   neutralIntensity)
        let blendFactor = 1 - ambientIntensity / neutralIntensity
        
        // 3
        for node in children {
            if let bug = node as? SKSpriteNode {
                bug.color = .black
                bug.colorBlendFactor = blendFactor
            }
        }
    }
    
    let touchSound = SKAction.playSoundFileNamed("sprayFirebug", waitForCompletion: false)
    override func touchesBegan(_ touches: Set<UITouch>,
                               with event: UIEvent?) {
        // Get the first touch
        guard let touch = touches.first else {
            return
        }
        // Get the location in the AR scene
        let location = touch.location(in: self)
        // Get the nodes at that location
        let hit = nodes(at: location)
        // Get the first node (if any)
        if let node = hit.first {
            // Check if the node is a memory (remember that labels are also a node)
            if node.name == "smile" {
                print ("touched")
                let fadeOut = SKAction.fadeOut(withDuration: 0.5)
                let remove = SKAction.removeFromParent()
                
                // Group the fade out and sound actions
                let groupActions = SKAction.group([fadeOut, touchSound])
                // Create an action sequence
                let sequenceAction = SKAction.sequence([groupActions, remove])
                //Excecute the actions
                node.run(sequenceAction)
            }
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("ended")
        
        
        //        let vc = ExploreViewController()
        //
        ////        vc.performSegue(withIdentifier: "displayViewSegue", sender: nil)
        //        vc.displayPhoto(shouldDisplay: true)
        //               self.photoDelegate?.displayPhoto(shouldDisplay: true)
        
        for touch in (touches ) {
            let location = touch.location(in: self)
            
            //            if self.nodeAtPoint(location) == self.WebButton{
//            retrieveURLFromDatabase()
            var url = "https://firebasestorage.googleapis.com/v0/b/locketinfo.appspot.com/o/theImage.png?alt=media&token=e68ec9c7-47e0-4117-9883-7f5ce07a8b08"
            UIApplication.shared.openURL(NSURL(string: url as! String)! as URL)
            
        }
    }
    
    func retrieveURLFromDatabase() {
        ref = Database.database().reference()
        
        //***Robbi's addition
        //retrieve posts and listen for changes
        databaseHandle = ref?.child("users").observe(.childAdded , with: { (snapshot) in
            let post = snapshot.value as? String
            if let actualPost = post{
                self.photoData.append(actualPost)
                //show in a popup
            }
        }) //change to name of table, maybe user email or id
        
        
        
        //***
        var newRef = ref.child("User").child("ImageLocation")
        
        
        newRef.observeSingleEvent(of: .value) { (snapshot) in
            print("------")
            print(snapshot)
            print("-------")
        }
        //The user have to provide the user part so they can access it
       
        
        Database.database().reference().child("User").child("ImageLocation").observeSingleEvent(of: .value, with: { (snapshot) in
            if let url = snapshot.value {
                print(url) // the url is the retrived value
                
                DispatchQueue.main.async {                   UIApplication.shared.openURL(NSURL(string: url as! String)! as URL)
                }
                 //you can add your link here
                //            }
                
                //                self.getDataFromUrl(url: URL(string: url as! String)!, completion: {x,y,error in
                //                    if error != nil {
                //                        print(error)
                //                    }
                //                })
            }
        }, withCancel: nil)
    }
    
    
    //  private var label : SKLabelNode?
    //  private var spinnyNode : SKShapeNode?
    //
    //  override func didMove(to view: SKView) {
    //
    //    // Get label node from scene and store it for use later
    //    self.label = self.childNode(withName: "//helloLabel") as? SKLabelNode
    //    if let label = self.label {
    //      label.alpha = 0.0
    //      label.run(SKAction.fadeIn(withDuration: 2.0))
    //    }
    //
    //    // Create shape node to use during mouse interaction
    //    let w = (self.size.width + self.size.height) * 0.05
    //    self.spinnyNode = SKShapeNode.init(rectOf: CGSize.init(width: w, height: w), cornerRadius: w * 0.3)
    //
    //    if let spinnyNode = self.spinnyNode {
    //      spinnyNode.lineWidth = 2.5
    //
    //      spinnyNode.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(Double.pi), duration: 1)))
    //      spinnyNode.run(SKAction.sequence([SKAction.wait(forDuration: 0.5),
    //                                        SKAction.fadeOut(withDuration: 0.5),
    //                                        SKAction.removeFromParent()]))
    //    }
    //  }
    //
    //
    //  func touchDown(atPoint pos : CGPoint) {
    //    if let n = self.spinnyNode?.copy() as! SKShapeNode? {
    //      n.position = pos
    //      n.strokeColor = SKColor.green
    //      self.addChild(n)
    //    }
    //  }
    //
    //  func touchMoved(toPoint pos : CGPoint) {
    //    if let n = self.spinnyNode?.copy() as! SKShapeNode? {
    //      n.position = pos
    //      n.strokeColor = SKColor.blue
    //      self.addChild(n)
    //    }
    //  }
    //
    //  func touchUp(atPoint pos : CGPoint) {
    //    if let n = self.spinnyNode?.copy() as! SKShapeNode? {
    //      n.position = pos
    //      n.strokeColor = SKColor.red
    //      self.addChild(n)
    //    }
    //  }
    //
    //  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    //    if let label = self.label {
    //      label.run(SKAction.init(named: "Pulse")!, withKey: "fadeInOut")
    //    }
    //
    //    for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    //  }
    //
    //  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    //    for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    //  }
    //
    //  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    //    for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    //  }
    //
    //  override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    //    for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    //  }
    //
    //
    //  override func update(_ currentTime: TimeInterval) {
    //    // Called before each frame is rendered
    //  }
}
