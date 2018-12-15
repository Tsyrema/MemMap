//
//  MapViewController.swift
//  Locket
//
//

import UIKit
import GoogleMaps
import CoreLocation
import FirebaseDatabase
import FirebaseAuth

class MapViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate {
    let locationManager = CLLocationManager()
    
    var databaseRef:DatabaseReference!
    var databaseHandle:DatabaseHandle!
    var locationmarker:GMSMarker!
    var mapView:GMSMapView!
    var distancelat:CLLocationDistance!
    var distancelong:CLLocationDistance!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        databaseRef = Database.database().reference()
        
        self.locationManager.delegate=self
        self.locationManager.desiredAccuracy=kCLLocationAccuracyNearestTenMeters
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        
        // Do any additional setup after loading the view.
        
        let camera = GMSCameraPosition.camera(withLatitude: (self.locationManager.location?.coordinate.latitude)!, longitude: (self.locationManager.location?.coordinate.longitude)!, zoom: 18.0)
        
        let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        
        mapView.isMyLocationEnabled = true      // blue dot
        mapView.settings.myLocationButton = true    // my location button
        view = mapView
        
        // retrieve geoLocation fromdatabase
        
        let currentUser = Auth.auth().currentUser?.uid
        databaseHandle = databaseRef.child("Users").child(currentUser!).child("images").observe(.childAdded , with: { (snapshot) in
            //print ("snapshot::::::::::",snapshot)
            let imageData = snapshot.value as! [String: AnyObject]
            let n = imageData["title"] as! String
            let la = imageData["geoLocationLat"] as! CLLocationDegrees
            let lo = imageData["geoLocationLong"] as! CLLocationDegrees
        
            let position = CLLocationCoordinate2D(latitude: la, longitude: lo)
            let locationmarker = GMSMarker(position: position)
            locationmarker.title = n
            locationmarker.map = mapView
            locationmarker.isTappable = true
            
        })
        
    }
    
    
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        
        print("tapped on marker")
        let distancelat =  marker.position.latitude.distance(to: (self.locationManager.location?.coordinate.latitude)!)
        let distancelong =  marker.position.longitude.distance(to: (self.locationManager.location?.coordinate.longitude)!)
        if distancelat < 1.0 && distancelong < 1.0 {
            print("show image")
        } else {
            print("not in this location")
        }
        return true
    }
    
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
