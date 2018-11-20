//
//  LoginViewController.swift
//  Locket
//
//  

//import Foundation
import UIKit
import FirebaseAuth
import FirebaseDatabase

class LoginViewController: UIViewController, UIAlertViewDelegate, UITextFieldDelegate {
    
    
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
        loginCheck()
    }
    
    func loginCheck() {
        if Auth.auth().currentUser != nil {
            //            let tabs = UITabBarController()
            //            tabs.viewControllers = [FreebiesViewController(), PostViewController(), SettingsViewController()]
            //            self.present(tabs, animated: true, completion: nil)
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let tbvc = storyboard.instantiateViewController(withIdentifier: "TabBarVC")
            self.present(tbvc, animated: true, completion: nil)
        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        
        if let email = emailTextField.text, let password = passwordTextField.text {
            
            Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
                if let error = error {
                    print("User Login Error \(error.localizedDescription)")
                    let alert = UIAlertController(title: "Login Failed!", message: "Failed to Login. Please Check Your Email and Password!", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    self.clearTextFields()
                }
                else {
                    
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let tbvc = storyboard.instantiateViewController(withIdentifier: "TabBarVC")
                    let alertController = UIAlertController(title: "Login Successful!", message: nil, preferredStyle: .alert)
                    self.present(alertController, animated: true, completion: nil)
                    self.clearTextFields()
                    
                    alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
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
