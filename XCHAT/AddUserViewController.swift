//
//  AddUserViewController.swift
//  XCHAT
//
//  Created by Mateo Garcia on 9/9/16.
//  Copyright © 2016 Mateo Garcia. All rights reserved.
//

import UIKit
import Parse
import MBProgressHUD

class AddUserViewController: UIViewController {
    
    @IBOutlet weak var loginView: UIView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var nameTextFieldHeight: NSLayoutConstraint!
    @IBOutlet weak var nameTextFieldBottomSpacing: NSLayoutConstraint!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var emailTextFieldHeight: NSLayoutConstraint!
    @IBOutlet weak var emailTextFieldBottomSpacing: NSLayoutConstraint!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var usernameTextFieldBottomSpacing: NSLayoutConstraint!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordTextFieldHeight: NSLayoutConstraint!
    @IBOutlet weak var passwordTextFieldBottomSpacing: NSLayoutConstraint!
    @IBOutlet weak var addUserButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Name text field.
        self.nameTextField.attributedPlaceholder = NSAttributedString(string: "Name", attributes: [NSForegroundColorAttributeName : UIColor.white])
        self.nameTextField.keyboardAppearance = UIKeyboardAppearance.dark
        self.nameTextField.delegate = self
        self.nameTextField.returnKeyType = .next
        
        // Email text field.
        self.emailTextField.attributedPlaceholder = NSAttributedString(string: "Email", attributes: [NSForegroundColorAttributeName : UIColor.white])
        self.emailTextField.keyboardAppearance = UIKeyboardAppearance.dark
        self.emailTextField.delegate = self
        self.nameTextField.nextTextField = self.emailTextField
        self.emailTextField.keyboardType = .emailAddress
        self.emailTextField.returnKeyType = .next
        
        // Username text field.
        self.usernameTextField.attributedPlaceholder = NSAttributedString(string: "Username", attributes: [NSForegroundColorAttributeName : UIColor.white])
        self.usernameTextField.keyboardAppearance = UIKeyboardAppearance.dark
        usernameTextField.delegate = self
        self.emailTextField.nextTextField = self.usernameTextField
        self.usernameTextField.returnKeyType = .next
        
        // Password text field.
        self.passwordTextField.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSForegroundColorAttributeName : UIColor.white])
        self.passwordTextField.keyboardAppearance = UIKeyboardAppearance.dark
        passwordTextField.delegate = self
        self.usernameTextField.nextTextField = self.passwordTextField
        self.passwordTextField.returnKeyType = .go
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = UIColor.clear
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        self.navigationController?.navigationBar.shadowImage = nil
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


// MARK: - Helpers

extension AddUserViewController {
    func dismissByPopping() {
        self.navigationController?.popViewController(animated: true)
    }
}


// MARK: - Text Field Delegate

extension AddUserViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField.returnKeyType {
        case .go:
            self.addUserButton.sendActions(for: .touchUpInside)
        default:
            textField.nextTextField?.becomeFirstResponder()
        }
        return true
    }
}


// MARK: - Actions

extension AddUserViewController {
    @IBAction func onAddUserButtonTapped(_ sender: AnyObject) {
        
        print("ADD USER")
        
        let user = PFUser()
        user.email = emailTextField.text
        user.username = usernameTextField.text
        user.password = passwordTextField.text
        user["totalNumFavesReceived"] = 0
        user["totalNumPhotosPosted"] = 0
        
        // other fields can be set just like with PFObject
        // user["phone"] = "415-392-0202"
        
        let currentHUD = MBProgressHUD.showAdded(to: self.view, animated: true)
        currentHUD.label.text = "Adding User..."
        
        user.signUpInBackground { (succeeded: Bool, error: Error?) -> Void in
            if let error = error {
                let errorString = error.localizedDescription
                
                // Show the errorString somewhere and let the user try again.
                print("Signup error: \(errorString)")
                
                MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
                let invalidSignupAlertVC = UIAlertController(title: "Email or Username Taken", message: "Please try again.", preferredStyle: UIAlertControllerStyle.alert)
                invalidSignupAlertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(invalidSignupAlertVC, animated: true, completion: nil)
                
            } else {
                
                // Hooray! Let them use the app now.
                print("SIGNUP SUCCESSFUL")
                
                currentHUD.label.text = "User Added!"
                currentHUD.mode = MBProgressHUDMode.customView
                currentHUD.customView =  UIImageView(image: UIImage(named: "reset_success"))
                let delay: TimeInterval = 2.0
                currentHUD.hide(animated: true, afterDelay: delay)
                self.perform(#selector(self.dismissByPopping), with: self, afterDelay: delay)
            }
        }
    }
    
    @IBAction func onBackgroundTapped(_ sender: AnyObject) {
        self.view.endEditing(true)
    }
}
