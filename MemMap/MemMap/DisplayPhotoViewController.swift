//
//  DisplayPhotoViewController.swift
//  MemMap
//
//  Created by Tsyrema Mansheeva on 2/10/18.
//  Copyright © 2018 Madushani Lekam Wasam Liyanage. All rights reserved.
//

import UIKit

class DisplayPhotoViewController: UIViewController {
    @IBOutlet weak var displayImageView: UIImageView!
    
    var message = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print(message)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
