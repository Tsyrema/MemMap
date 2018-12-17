//
//  ExploreScene.swift
//  Locket
//
//  

import ARKit
import UIKit
import SpriteKit
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth
import CoreLocation

protocol DisplayPhotoDelegate {
    func displayPhoto (shouldDisplay: Bool)
}

class ExploreScene: SKScene {
    
    var photoDelegate: DisplayPhotoDelegate?

    var databaseRef:DatabaseReference!
    var databaseHandle:DatabaseHandle!
//    var storageReference
    static var locationArray = [dbObject]()
    
    let touchSound = SKAction.playSoundFileNamed("sprayFirebug", waitForCompletion: true)

    var sceneView: ARSKView {
        return view as! ARSKView
    }
    
    
    @IBOutlet weak var myImageView: UIImageView!
    
    //var myImageView = UIImageView()
    
    var isWorldSetUp = false
    var image = UIImage()

//    var arrCount = 0
    let numberLabel = SKLabelNode(text: "0")
    var nodeCount = 0 {
        didSet{
            self.numberLabel.text = "\(nodeCount)"
        }
    }
    
    // Adding a picture
    func setUpWorld() {
        //check whether the session has an initialized currentFrame
//        guard let currentFrame = sceneView.session.currentFrame
//            else { return }
        
        retrieveFromDatabase()
        
        print("here::::::::::::::::::::::::", ExploreScene.locationArray)
        for i in 1...4{
             //Define 360º in radians
            let _180degrees = 1.0 * Float.pi

            // Create a rotation matrix in the X-axis
            let rotateX = simd_float4x4(SCNMatrix4MakeRotation(_180degrees * randomFloat(min: 0.0, max: 0.5), 1, 0, 0))

            // Create a rotation matrix in the Y-axis
            let rotateY = simd_float4x4(SCNMatrix4MakeRotation(_180degrees * randomFloat(min: 0.0, max: 0.5), 0, 1, 0))

            // Combine both rotation matrices
            let rotation = simd_mul(rotateX, rotateY)

            // Create a translation matrix in the Z-axis with a value between 1 and 2 meters
            var translation = matrix_identity_float4x4
            translation.columns.3.z = -1 - randomFloat(min: 0.0, max: 1)

            // Combine the rotation and translation matrices
            let transform = simd_mul(rotation, translation)
        
      
//        // create a four-dimensional identity matrix. Rotation and scaling use the first three columns
//        var translation = matrix_identity_float4x4
//        translation.columns.3.z = -1 - randomFloat(min: 0.0, max: 1)
//
//        let transform =
//            currentFrame.camera.transform * translation
        
            // Create an anchor
        let anchor = ARAnchor(name:"\(nodeCount)", transform: transform)
            sceneView.session.add(anchor: anchor)
            print("anchor added:::::::::::::::::")
        nodeCount += 1
        }
        
        isWorldSetUp = true
    }
    
    override func didMove(to view: SKView) {
        numberLabel.fontSize = 30
        numberLabel.fontName = "DevanagariSangamMN-Bold"
        numberLabel.color = .white
        numberLabel.position = CGPoint(x: 40, y: 80)
        addChild(numberLabel)
    }
    
    //create random float between specified ranges
    func randomFloat(min: Float, max: Float) -> Float {
        return (Float(arc4random()) / 0xFFFFFFFF) * (max - min) + min
    }
    
    
    // this is called every frame
    override func update(_ currentTime: TimeInterval) {
        if !isWorldSetUp {
            //for index in 1...4{
            setUpWorld()
//            }
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
//            var hitBug: SKNode?
//            for node in hit {
//                if node.name == "bug" {
//                    hitBug = node
//                    break
//                }
//            }
//
            if node.name == "\(nodeCount)" {
                print ("touched")
                let fadeOut = SKAction.fadeOut(withDuration: 0.5)
                let remove = SKAction.removeFromParent()
                
                // Group the fade out and sound actions
                let groupActions = SKAction.group([fadeOut, touchSound])
                // Create an action sequence
                let sequenceAction = SKAction.sequence([groupActions, remove])
                //Excecute the actions
                node.run(sequenceAction)
                nodeCount -= 1
                print ("node cont:::::::::", nodeCount)
                retrieveFromStorage(name: node.name ?? "azkGx8004133616199252354.png")
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
        nodeCount -= 1
        print ("node cont:::::::::", nodeCount)
        for touch in (touches ) {
            let location = touch.location(in: self)
            
            
            //            if self.nodeAtPoint(location) == self.WebButton{
//            retrieveURLFromDatabase()
            var url = "https://firebasestorage.googleapis.com/v0/b/mymemmap.appspot.com/o/azkGxMR3jhaTlALeLShAuhVYa563%2FImages%2FazkGx-6953890196988142930.png?alt=media&token=94a59a28-470e-433d-9af3-283cb17c80e7"
            UIApplication.shared.openURL(NSURL(string: url as! String)! as URL)
            
        }
    }

    func retrieveFromStorage(name : String){
        databaseRef = Database.database().reference()
        let currentUser = Auth.auth().currentUser?.uid
        let userRef = databaseRef.child("Users").child(currentUser!)
        let storageRef = Storage.storage().reference()
        let imageRef = storageRef.child(name)   //("azkGx8004133616199252354.png")
        storageRef.getData(maxSize: 1 * 1024 * 1024) { (data, error) -> Void in
            if (error != nil) {
                print(error)
            } else {
                self.myImageView.image = UIImage(data: data!)
            }
        }
        
    }
    
    func retrieveFromDatabase() {
        databaseRef = Database.database().reference()
        let currentUser = Auth.auth().currentUser?.uid
        databaseHandle = databaseRef.child("Users").child(currentUser!).child("images").observe(.childAdded , with: { (snapshot) in
            let imageData = snapshot.value as! [String: AnyObject]
            //print("snapshot::::::::::", imageData)
            let n = imageData["title"] as! String
            let la = imageData["geoLocationLat"] as! CLLocationDegrees
            let lo = imageData["geoLocationLong"] as! CLLocationDegrees
            let clloc = CLLocation(latitude: la, longitude: lo)
            let loc = dbObject(name: n, loc: clloc)
            ExploreScene.locationArray.append(loc)
            //            self.arrCount += 1
        })
        print("locArray:::::::::::::", ExploreScene.locationArray)
    }
    
    struct dbObject{
        let name: String
        let loc: CLLocation
    }
    
}
