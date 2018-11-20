//
//  CameraViewController.swift
//  Locket
//
//

import UIKit
import SceneKit
import ARKit
import AVFoundation
import FirebaseStorage
import FirebaseDatabase
import CoreLocation
import FirebaseAuth


class CameraViewController: UIViewController, UITextFieldDelegate {
    let locationManager = CLLocationManager()
    @IBOutlet var captureButton: UIButton!
    @IBOutlet var swapButton: UIButton!
    @IBOutlet var addButton: UIButton!
    
    @IBOutlet var titleTextField: UITextField!
    @IBOutlet var previewView: UIView!
    @IBOutlet var tempImageView: UIImageView!
    
    var captureSession: AVCaptureSession?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var stillImageOutput: AVCaptureStillImageOutput?
    var captureDevice: AVCaptureDevice?
    var capturedImage: UIImage?
    
    var usingFrontCamera = false
    
    var zoomLevel: Float = 15.0
    
    
    var storRef:StorageReference!
    var ref:DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleTextField.delegate = self
        loadCamera()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        videoPreviewLayer!.frame = self.previewView.bounds
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func takePhotoTapped(_ sender: UIButton) {
        
        print("Tapped")
        if let videoConnection = stillImageOutput?.connection(with: .video) {
            
            videoConnection.videoOrientation = AVCaptureVideoOrientation.portrait
            stillImageOutput?.captureStillImageAsynchronously(from: videoConnection, completionHandler: {
                
                (sampleBuffer, error) in
                if sampleBuffer != nil {
                    
                    let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer!)
                    let dataProvider = CGDataProvider.init(data: imageData! as CFData)
                    let cgImageRef = CGImage.init(jpegDataProviderSource: dataProvider!, decode: nil, shouldInterpolate: true, intent: .defaultIntent)
                    
                    self.capturedImage = UIImage (cgImage: cgImageRef!, scale: 1.0, orientation: UIImageOrientation.right)
                    
                    self.capturedImage = self.capturedImage?.resizeImage()
                    self.tempImageView.image = self.capturedImage
                    self.tempImageView.isHidden = false
                    self.swapButton.isHidden = true
                    self.captureButton.isHidden = true
                    self.addButton.isHidden = false
                    self.titleTextField.isHidden = false
                }
            })
        }
        
    }
    
    @IBAction func swapTapped(_ sender: UIButton) {
        usingFrontCamera = !usingFrontCamera
        loadCamera()
        
    }
    
    @IBAction func addButtonTapped(_ sender: UIButton) {
        
        dump(capturedImage)
        
        let storageRef = Storage.storage().reference().child("theImage.png")
        let uploadData = UIImagePNGRepresentation(capturedImage!)
        storageRef.putData(uploadData!, metadata: nil)
        
        ref = Database.database().reference()
        ref?.child("User").setValue("user") //change to user information, maybe email or id
        ref?.child("GeoLocation").setValue("\(String(describing: self.locationManager.location?.coordinate.latitude))"+",\(String(describing: self.locationManager.location?.coordinate.longitude))")
        
        storageRef.getMetadata { (metadata, error) in
            if error != nil {
                print("error")
            }
            else {
                let urlUn = StorageMetadata.downloadURL(metadata!)
                let url = urlUn()!.absoluteString
                self.ref = Database.database().reference()
                self.ref?.child("ImageLocation").setValue(url)
            }
        }
        tempImageView.isHidden = true
        previewView.isHidden = false
        addButton.isHidden = true
        titleTextField.isHidden = true
        captureButton.isHidden = false
        swapButton.isHidden = false
        //        dump(location?.coordinate.longitude)
        
        
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
    
    func getFrontCamera() -> AVCaptureDevice?{
        let videoDevices = AVCaptureDevice.devices(for: .video)
        
        for device in videoDevices {
            let device = device
            if device.position == AVCaptureDevice.Position.front {
                return device
            }
        }
        return nil
    }
    
    func getBackCamera() -> AVCaptureDevice{
        return AVCaptureDevice.default(for: .video )!
    }
    func loadCamera() {
        if(captureSession == nil){
            captureSession = AVCaptureSession()
            captureSession!.sessionPreset = AVCaptureSession.Preset.photo
        }
        var error: NSError?
        var input: AVCaptureDeviceInput!
        
        captureDevice = (usingFrontCamera ? getFrontCamera() : getBackCamera())
        
        do {
            input = try AVCaptureDeviceInput(device: captureDevice!)
        } catch let error1 as NSError {
            error = error1
            input = nil
            print(error!.localizedDescription)
        }
        
        for i : AVCaptureDeviceInput in (self.captureSession?.inputs as! [AVCaptureDeviceInput]){
            self.captureSession?.removeInput(i)
        }
        
        if error == nil && captureSession!.canAddInput(input) {
            captureSession!.addInput(input)
            stillImageOutput = AVCaptureStillImageOutput()
            stillImageOutput?.outputSettings = [AVVideoCodecKey: AVVideoCodecType.jpeg]
            if captureSession!.canAddOutput(stillImageOutput!) {
                captureSession!.addOutput(stillImageOutput!)
                videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
                videoPreviewLayer!.videoGravity = AVLayerVideoGravity.resizeAspectFill
                videoPreviewLayer!.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
                //self.cameraPreviewSurface.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
                self.previewView.layer.addSublayer(videoPreviewLayer!)
                DispatchQueue.main.async {
                    self.captureSession!.startRunning()
                }
                
            }
        }
        
        
        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            if let loc = locations.first {
                print(loc.coordinate)
                
            }
        }
        
        // If we have been deined access give the user the option to change it
        func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
            if(status == CLAuthorizationStatus.denied) {
                //                showLocationDisabledPopUp()
            }
        }
        
        
        
        // Handle location manager errors.
        func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
            //            self.locationManager.stopUpdatingLocation()
            print("Error: \(error)")
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
    
    
}
extension UIImage{
    func resizeImage() -> UIImage {
        //        let horizontalRatio = CGSize(width: 100, height: 100)
        //        let verticalRatio = newSize.height / size.height
        //        let ratio = max(horizontalRatio, verticalRatio)
        let newSize = CGSize(width: 600, height: 600)
        UIGraphicsBeginImageContextWithOptions(newSize, true, 0)
        draw(in: CGRect(origin: CGPoint(x: 0, y: 0), size: newSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
}


