//
//  DisplayPhotoViewController.swift
//  Locket
//
// 

import UIKit
import FirebaseStorage
import FirebaseDatabase
import FirebaseAuth

class DisplayPhotoViewController: UIViewController {
    @IBOutlet weak var displayImageView: UIImageView!
    
    var message = false
    @IBOutlet var logoutButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        displayImageView.layer.cornerRadius = 10
        displayImageView.layer.masksToBounds = true
        print(message)
        let storageRef = Storage.storage().reference().child("Images")
        
        let databaseRef = Database.database().reference()
        let imageName = Database.database().reference().child("Images").value(forKey: "title")
        let imageData = storageRef.child("Images").child("\(imageName)")
        var image : UIImage = UIImage(named: imageName as! String)!
        displayImageView = UIImageView(image: image)
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
