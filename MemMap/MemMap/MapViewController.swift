//
//  MapViewController.swift
//  MemMap
//
//  Created by Madushani Lekam Wasam Liyanage on 2/10/18.
//  Copyright © 2018 Madushani Lekam Wasam Liyanage. All rights reserved.
//

import UIKit
import GoogleMaps

class MapViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let camera = GMSCameraPosition.camera(withLatitude:41.80 , longitude: -87.59, zoom: 6.0)
        let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        view = mapView
        
        // Creates a marker in the center of the map.
        let marker = GMSMarker()
//        41.7997° N, 87.5897° W
        marker.position = CLLocationCoordinate2D(latitude:41.80 , longitude: -87.59)
        marker.title = "Uncommon Hacks 2018"
        marker.snippet = "Polsky Exchange"
        marker.map = mapView
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
