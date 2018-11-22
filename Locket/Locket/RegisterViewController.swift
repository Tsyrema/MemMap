//
//  RegisterViewController.swift
//  Locket
//
//

//import Foundation
import UIKit
import FirebaseAuth
import FirebaseDatabase

class RegisterViewController: UIViewController, UIAlertViewDelegate, UITextFieldDelegate {
    
    
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    var databaseRef: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userNameTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        databaseRef = Database.database().reference()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
   
    @IBAction func registerButtonTapped(_ sender: UIButton) {
        if let email = emailTextField.text,
            let password = passwordTextField.text,
            let name = userNameTextField.text {
            
            Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
                if let error = error {
                    print("User Creating Error \(error.localizedDescription)")
                    let alert = UIAlertController(title: "Signup Failed!", message: "Failed to Register. Please Try Again!", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    self.clearTextFields()
                }
                else {
                    let postDict = ["name": name, "email": email] as [String:Any]
                    
                    let currentUser = Auth.auth().currentUser?.uid
                    self.databaseRef.child("Users").child(currentUser!).setValue(postDict)
                    
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let tbvc = storyboard.instantiateViewController(withIdentifier: "TabBarVC")
                    let alertController = UIAlertController(title: "Signup Successful!", message: nil, preferredStyle: .alert)
                    self.present(alertController, animated: true, completion: nil)
                    
                    alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: { (action: UIAlertAction!) in
                        self.present(tbvc, animated: true, completion: nil)
                    }))
                }
            })
        }
    }
    
    func clearTextFields() {
        emailTextField.text = nil
        passwordTextField.text = nil
        userNameTextField.text = nil
    }
    
}
