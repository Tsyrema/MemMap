//
//  ExploreViewController.swift
//  Locket
//
//

import ARKit
import SpriteKit
import FirebaseDatabase
import FirebaseAuth
import CoreLocation

class ExploreViewController: UIViewController, ARSKViewDelegate {

    
    @IBOutlet var sceneView: ARSKView!
    
    var ref:DatabaseReference!

    var url: String!
    var photoData = [String]()
    var databaseRef:DatabaseReference!
    var databaseHandle:DatabaseHandle!
    var locationArray = [dbObject]()


    @IBOutlet var logoutButton: UIButton!

//    var sceneView: ARSKView!

    let image = UIImage()
//    var imageView = UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        databaseRef = Database.database().reference()
        //retrieveURLFromDatabase()
        if let view = self.view as? ARSKView {
            let scene = ExploreScene(size: view.bounds.size)

            sceneView = view
            sceneView.delegate = self
            //addTargetNodes()

            scene.scaleMode = .resizeFill
            //scene.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            view.presentScene(scene)
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }


    @IBAction func LogoutButtonTapped(_ sender: UIButton) {
        let signOutAction = UIAlertAction(title: "Sign Out", style: UIAlertActionStyle.destructive){(action)in
            do{
                try Auth.auth().signOut()
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let livc = storyboard.instantiateViewController(withIdentifier: "LandingVC")
                self.present(livc, animated: true, completion: nil)
            } catch {
                print ("Error while signing out")
                let alert = UIAlertController(title: "Sign out error", message: "Error while signing out", preferredStyle: .alert)
                self.present(alert, animated: true, completion: nil)
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let signoutAlertSheet = UIAlertController(title: nil , message: nil , preferredStyle: .actionSheet)
        signoutAlertSheet.addAction(signOutAction)
        signoutAlertSheet.addAction(cancelAction)
        self.present(signoutAlertSheet, animated: true, completion: nil)
    }



    func retrieveURLFromDatabase() {

        let currentUser = Auth.auth().currentUser?.uid
        databaseHandle = databaseRef.child("Users").child(currentUser!).child("images").observe(.childAdded , with: { (snapshot) in
            let imageData = snapshot.value as! [String: AnyObject]
            let n = imageData["title"] as! String
            let la = imageData["geoLocationLat"] as! CLLocationDegrees
            let lo = imageData["geoLocationLong"] as! CLLocationDegrees
            let clloc = CLLocation(latitude: la, longitude: lo)
            let loc = dbObject(name: n, loc: clloc)

            self.locationArray.append(loc)
            print ("location array::::::::::",self.locationArray)
        })

    }

    struct dbObject{
        let name: String
        let loc: CLLocation
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingConfiguration()

        sceneView?.session.run(configuration)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView?.session.pause()
    }
    
    // MARK: - ARSKViewDelegate
    func session(_ session: ARSession,
                 didFailWithError error: Error) {
        print("Session Failed - probably due to lack of camera access")
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        print("Session interrupted")
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        print("Session resumed")
        sceneView.session.run(session.configuration!,
                              options: [.resetTracking,
                                        .removeExistingAnchors])
    }
    
    // attach a heart to anchor
    func view(_ view: ARSKView,
              nodeFor anchor: ARAnchor) -> SKNode? {
        
        let pic = SKSpriteNode(imageNamed: "pin3")
        pic.position = CGPoint(x: CGFloat(randomFloat(min: -10, max: 10)),y: CGFloat(randomFloat(min: -4, max: 5 )))
//        pic.name = "pin3"
        return pic
    }

    
    func addTargetNodes(){
        retrieveURLFromDatabase()
        for obj in locationArray{
            print ("object::::::::", obj)
            //let newNode = SKNode()
            let pic = SKSpriteNode(imageNamed: "pin3")
            pic.name = obj.name
            pic.position = CGPoint(x: CGFloat(randomFloat(min: -10, max: 10)),y: CGFloat(randomFloat(min: -4, max: 5 )))
            print("nodes added")
            sceneView.scene!.addChild(pic)
            //sceneView.scene.rootNode.addChildNode(pic)
        }
    }
    
    //create random float between specified ranges
    func randomFloat(min: Float, max: Float) -> Float {
        return (Float(arc4random()) / 0xFFFFFFFF) * (max - min) + min
    }
    
}




/*
 // MARK: - Navigation

 // In a storyboard-based application, you will often want to do a little preparation before navigation
 override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
 // Get the new view controller using segue.destinationViewController.
 // Pass the selected object to the new view controller.
 }
 */

