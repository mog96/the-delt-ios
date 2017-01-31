//
//  LoginViewController.swift
//  XCHAT
//
//  Created by Mateo Garcia on 5/13/15.
//  Copyright (c) 2015 Mateo Garcia. All rights reserved.
//


import UIKit
import MessageUI
import Parse
import Reachability

class LoginViewController: UIViewController {
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var deltLoadingView: DeltLoadingView!
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
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextFieldHeight: NSLayoutConstraint!
    @IBOutlet weak var confirmPasswordTextFieldBottomSpacing: NSLayoutConstraint!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var resetPasswordButton: UIButton!
    
    var loginLabel: UILabel!
    var loginLabelOriginalOrigin: CGPoint!
    
    let loginString = "LOG IN"
    let loggingInString = "LOGGING IN..."
    let resetPasswordString = "RESET PASSWORD"
    let resettingPasswordString = "RESETTING PASSWORD..."
    
    var loginButtonOriginalColor: UIColor!
    var signupButtonOriginalColor: UIColor!
    
    var textFieldOriginalHeight: CGFloat!
    var textFieldOriginalBottomSpacing: CGFloat!
    
    var textFields: [UITextField]!
    var signupTextFieldHeightConstraints: [NSLayoutConstraint]!
    var signupTextFieldBottomSpacingConstraints: [NSLayoutConstraint]!
    var controlsHiddenOnLogin: [UIControl]!
    
    let loginBackgroundImageNames = ["LOGIN BACKGROUND 1",
                                     "LOGIN BACKGROUND 2",
                                     "LOGIN BACKGROUND 3",
                                     "LOGIN BACKGROUND 4",
                                     "LOGIN BACKGROUND 5",
                                     // "TORTOISE",
                                     "OUTER SPACE"]
    var loginBackgroundImageIndex = 0
    
    var lastFirstResponder: UITextField?
    
    var inSignupMode = true
    var shouldContinueAnimating = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.backgroundImageView.image = UIImage(named: self.loginBackgroundImageNames[self.loginBackgroundImageIndex])
        
        self.deltLoadingView.isHidden = true
        self.resetPasswordButton.isHidden = true
        
        self.textFieldOriginalHeight = self.nameTextFieldHeight.constant
        self.textFieldOriginalBottomSpacing = self.nameTextFieldBottomSpacing.constant
        
        // Name text field.
        self.nameTextField.attributedPlaceholder = NSAttributedString(string: "Name", attributes: [NSForegroundColorAttributeName : UIColor.lightText])
        self.nameTextField.keyboardAppearance = UIKeyboardAppearance.dark
        self.nameTextField.delegate = self
        self.nameTextField.returnKeyType = .next
        
        // Email text field.
        self.emailTextField.attributedPlaceholder = NSAttributedString(string: "Email", attributes: [NSForegroundColorAttributeName : UIColor.lightText])
        self.emailTextField.keyboardAppearance = UIKeyboardAppearance.dark
        self.emailTextField.delegate = self
        self.nameTextField.nextTextField = self.emailTextField
        self.emailTextField.keyboardType = .emailAddress
        self.emailTextField.returnKeyType = .next
        
        // Username text field.
        self.usernameTextField.attributedPlaceholder = NSAttributedString(string: "Username", attributes: [NSForegroundColorAttributeName : UIColor.lightText])
        self.usernameTextField.keyboardAppearance = UIKeyboardAppearance.dark
        usernameTextField.delegate = self
        self.emailTextField.nextTextField = self.usernameTextField
        self.usernameTextField.returnKeyType = .next
        
        // Password text field.
        self.passwordTextField.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSForegroundColorAttributeName : UIColor.lightText])
        self.passwordTextField.keyboardAppearance = UIKeyboardAppearance.dark
        passwordTextField.delegate = self
        self.usernameTextField.nextTextField = self.passwordTextField
        self.passwordTextField.returnKeyType = .go
        
        // Confirm password text field.
        self.confirmPasswordTextField.attributedPlaceholder = NSAttributedString(string: "Confirm", attributes: [NSForegroundColorAttributeName : UIColor.lightText])
        self.confirmPasswordTextField.keyboardAppearance = UIKeyboardAppearance.dark
        self.confirmPasswordTextField.delegate = self
        self.passwordTextField.nextTextField = self.confirmPasswordTextField
        self.confirmPasswordTextField.returnKeyType = .go
        self.confirmPasswordTextFieldHeight.constant = 0
        self.confirmPasswordTextFieldBottomSpacing.constant = 0
        self.confirmPasswordTextField.isHidden = true
        
        // Group buttons and text fields for animations.
        self.textFields = [self.nameTextField, self.emailTextField, self.usernameTextField, self.passwordTextField]
        self.signupTextFieldHeightConstraints = [self.nameTextFieldHeight, self.emailTextFieldHeight]
        self.signupTextFieldBottomSpacingConstraints = [self.nameTextFieldBottomSpacing, self.emailTextFieldBottomSpacing]
        self.controlsHiddenOnLogin = [self.usernameTextField, self.passwordTextField, self.signupButton]
        
        // Login and sign up button colors.
        self.loginButtonOriginalColor = self.loginButton.titleColor(for: UIControlState())
        self.signupButtonOriginalColor = self.signupButton.titleColor(for: UIControlState())
        
        // Show login text fields on load.
        self.showSignupMode(false)
        // Must come after above line to ensure login view is proper height.
        self.loginView.layer.cornerRadius = 4
        self.loginView.layer.masksToBounds = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.usernameTextField.becomeFirstResponder()
        
        self.addLoginLabel()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if let isAdmin = PFUser.current()?.object(forKey: "is_admin") as? Bool {
            AppDelegate.isAdmin = isAdmin
        } else {
            AppDelegate.isAdmin = false
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


// MARK: - Login Helpers

extension LoginViewController {
    fileprivate func logInUser(_ username: String, password: String) {
        let un = username.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let pw = password.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        // Local error checks.
        if un.characters.count == 0 {
            let ac = UIAlertController(title: "Invalid Username", message: "Please try again.", preferredStyle: UIAlertControllerStyle.alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(ac, animated: true, completion: nil)
            return
        } else if pw.characters.count == 0 {
            let ac = UIAlertController(title: "Invalid Password", message: "Please try again.", preferredStyle: UIAlertControllerStyle.alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(ac, animated: true, completion: nil)
            return
        }
        
        self.startLoginAnimation(fromResetPasswordMode: false)
        PFUser.logInWithUsername(inBackground: un, password: pw) { (user: PFUser?, error: Error?) -> Void in
            if let error = error {
                
                print("LOGIN FAILED")
                
                self.endLoginAnmation(inResetPasswordMode: false)
                
                print("LOGIN ERROR:", error._code)
                
                switch error._code {
                case 101:
                    let ac = UIAlertController(title: "Invalid Username or Password", message: "Please try again.", preferredStyle: UIAlertControllerStyle.alert)
                    ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(ac, animated: true, completion: nil)
                default:
                    let ac = UIAlertController(title: "Could not Connect", message: "Check your Internet connection and try again.", preferredStyle: UIAlertControllerStyle.alert)
                    ac.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                    self.present(ac, animated: true, completion: nil)
                }
            } else if let user = user {
                
                print("LOGIN SUCCESSFUL")
                
                /** SAVE DEVICE INSTALLATION **/
                
                // Save username to NSUserDefaults in case PFUser.currentUser() fails in share extension.
                UserDefaults(suiteName: "group.com.tdx.thedelt")?.set(user.username!, forKey: "Username")
                let installation = PFInstallation.current()!
                installation["user"] = PFUser.current()!
                installation["username"] = PFUser.current()!.username!
                installation.saveInBackground(block: { (completed: Bool, error: Error?) in
                    print("USER SAVED TO INSTALLATION")
                })
                
                if password == "temp" {
                    self.passwordTextField.text = nil
                    self.endLoginAnmation(inResetPasswordMode: true)
                } else {
                    self.endLoginAnmation(inResetPasswordMode: false)
                    self.view.endEditing(true)
                    self.transitionToApp()
                }
            }
        }
    }
    
    /**
     After user logs in with temporary password,
     resets user's password and transitions to the app.
     */
    fileprivate func resetCurrentUserPassword(_ password: String) {
        PFUser.current()?.password = password
        PFUser.current()?.saveInBackground(block: { (completed: Bool, error: Error?) in
            if error != nil {
                print("Error:", error!.localizedDescription)
            } else {
                self.endLoginAnmation(inResetPasswordMode: true)
                self.view.endEditing(true)
                self.transitionToApp()
            }
        })
    }
}


// MARK: - Signup Helpers

/**
 NOTE: Current signup flow has poor function organization, due to chained callback functions.
       /** TODO **/ Future implementation should make use of promises.
 */
extension LoginViewController {
    fileprivate func isValidEmail(_ testStr: String) -> Bool {
        // print("validate calendar: \(testStr)")
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    fileprivate func beginSignupRequest(_ email: String) {
        if email.lowercased().hasSuffix("@stanford.edu") {
            let signupRequest = PFObject(className: "SignupRequest")
            signupRequest["name"] = self.nameTextField.text
            self.checkEmail(email, forRequest: signupRequest)
        } else {
            self.presentUnrecognizedUserSignupRequestMailCompose()
        }
    }
    
    fileprivate func checkEmail(_ email: String, forRequest signupRequest: PFObject) {
        let query = PFUser.query()
        query?.whereKey("email", equalTo: email)
        query?.findObjectsInBackground(block: { (objects: [PFObject]?, error: Error?) in
            if error != nil {
                print("Error:", error!.localizedDescription)
                self.presentErrorSubmittingRequestAlert()
            } else {
                if objects?.count == 0 {
                    signupRequest["email"] = email
                    if let username = self.usernameTextField.text {
                        self.checkUsername(username, forRequest: signupRequest)
                    } else {
                        let alert = UIAlertController(title: "Username Required", message: "Please enter a username.", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                } else {
                    let alert = UIAlertController(title: "Email In Use", message: "The email you entered is already associated with an account. If that doesn't sound right, please contact your Admin.", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        })
    }
    
    fileprivate func checkUsername(_ username: String, forRequest signupRequest: PFObject) {
        let query = PFUser.query()
        query?.whereKey("username", equalTo: username)
        query?.findObjectsInBackground(block: { (objects: [PFObject]?, error: Error?) in
            if error != nil {
                print("Error:", error!.localizedDescription)
                self.presentErrorSubmittingRequestAlert()
            } else {
                if objects?.count == 0 {
                    signupRequest["username"] = username
                    signupRequest.saveInBackground(block: { (completed: Bool, error: Error?) -> Void in
                        if let error = error {
                            // Log details of the failure
                            print("Error: \(error) \(error._userInfo)")
                            self.presentErrorSubmittingRequestAlert()
                            
                        } else {
                            let alert = UIAlertController(title: "Signup Request Submitted", message: "The Admin has received your request and will notify you by email when you are approved.", preferredStyle: UIAlertControllerStyle.alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { _ in
                                self.showSignupMode(false)
                                self.clearTextFields()
                            }))
                            self.present(alert, animated: true, completion: nil)
                        }
                    })
                } else {
                    let alert = UIAlertController(title: "Username Taken", message: "The username you requested is already taken. Please choose another.", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        })
    }
    
    fileprivate func presentErrorSubmittingRequestAlert() {
        let alert = UIAlertController(title: "Error Submitting Request", message: "Please try again.", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}


// MARK: - Helpers

extension LoginViewController {
    fileprivate func showSignupMode(_ show: Bool) {
        self.inSignupMode = show
        self.view.endEditing(true)
        
        let animationDuration = 0.35
        
        if show {
            self.signupTextFieldHeightConstraints.forEach({ $0.constant = self.textFieldOriginalHeight })
            self.signupTextFieldBottomSpacingConstraints.forEach({ $0.constant = self.textFieldOriginalBottomSpacing })
            self.passwordTextFieldHeight.constant = 0
            self.passwordTextFieldBottomSpacing.constant = 0
            self.usernameTextField.returnKeyType = .go
            
        } else {
            self.signupTextFieldHeightConstraints.forEach({ $0.constant = 0 })
            self.signupTextFieldBottomSpacingConstraints.forEach({ $0.constant = 0 })
            self.passwordTextFieldHeight.constant = self.textFieldOriginalHeight
            self.passwordTextFieldBottomSpacing.constant = self.textFieldOriginalBottomSpacing
            self.usernameTextField.returnKeyType = .next
        }
        
        self.loginView.setNeedsLayout()
        self.textFields.forEach({ $0.setNeedsLayout() })
        UIView.animate(withDuration: animationDuration, animations: { () -> Void in
            self.loginView.layoutIfNeeded()
            self.textFields.forEach({ $0.layoutIfNeeded() })
            self.loginButton.setTitleColor(show ? UIColor.darkGray : self.loginButtonOriginalColor, for: UIControlState())
            self.signupButton.setTitleColor(show ? self.loginButtonOriginalColor : self.signupButtonOriginalColor, for: UIControlState())
            
            }, completion: nil)

        [self.nameTextField, self.emailTextField].forEach { (textField: UITextField) in
            UIView.transition(with: textField, duration: animationDuration - 1, options: .transitionCrossDissolve, animations: {
                textField.isHidden = !show
                }, completion: nil)
            }
        
        UIView.transition(with: self.passwordTextField, duration: animationDuration - 1, options: .transitionCrossDissolve, animations: {
            self.passwordTextField.isHidden = show
            }, completion: { _ in
                if show {
                    self.passwordTextField.text =  nil
                }
        })
    }
    
    fileprivate func clearTextFields() {
        self.nameTextField.text = nil
        self.usernameTextField.text = nil
        self.emailTextField.text = nil
    }
}


// MARK: - Delt Animation Helpers

extension LoginViewController {
    // Login label used as duplicate of login button title label for animations.
    fileprivate func addLoginLabel() {
        self.loginLabel = UILabel()
        self.loginLabel.text = self.loginButton.titleLabel!.text
        self.loginLabel.textColor = self.loginButton.titleLabel!.textColor
        self.loginLabel.font = self.loginButton.titleLabel!.font
        let loginButtonTitleLabelFrame = self.loginButton.convert(self.loginButton.titleLabel!.frame, to: self.view)
        self.loginLabel.frame = CGRect(x: loginButtonTitleLabelFrame.origin.x, y: loginButtonTitleLabelFrame.origin.y, width: loginButtonTitleLabelFrame.width, height: loginButtonTitleLabelFrame.height)
        self.loginLabelOriginalOrigin = self.loginLabel.frame.origin
        self.loginLabel.isHidden = true
        self.view.addSubview(self.loginLabel)
        
        self.exemptLoginLabelFrameFromDeltAnimation()
    }
    
    fileprivate func exemptLoginLabelFrameFromDeltAnimation() {
        self.loginLabel.text = self.loggingInString
        self.loginLabel.sizeToFit()
        self.loginLabel.center.x = self.loginView.center.x
        self.deltLoadingView.addExemptFrames(self.loginLabel.frame)
        self.loginLabel.text = self.loginString
        self.loginLabel.sizeToFit()
        self.loginLabel.frame.origin.x = self.loginLabelOriginalOrigin.x
    }
    
    fileprivate func startLoginAnimation(fromResetPasswordMode: Bool) {
        self.view.endEditing(true)
        
        let animationDuration = 0.5
        self.shouldContinueAnimating = true
        
        self.loginLabel.isHidden = false
        self.loginButton.isHidden = true
        self.resetPasswordButton.isHidden = true
        UIView.animate(withDuration: animationDuration, animations: {
            if fromResetPasswordMode {
                self.loginLabel.text = self.resettingPasswordString
            } else {
                self.loginLabel.text = self.loggingInString
            }
            self.loginLabel.sizeToFit()
            self.loginLabel.center.x = self.loginView.center.x
        }, completion: { _ in
            self.pulseLoginLabel()
        }) 
        
        UIApplication.shared.setStatusBarHidden(true, with: .fade)
        UIView.transition(with: self.backgroundImageView, duration: animationDuration, options: .transitionCrossDissolve, animations: {
            self.backgroundImageView.alpha = 0
            self.loginBackgroundImageIndex = (self.loginBackgroundImageIndex + 1) % self.loginBackgroundImageNames.count
            }, completion: { _ in
//                self.loginBackgroundImageIndex = (self.loginBackgroundImageIndex + 1) % self.loginBackgroundImageNames.count
                self.backgroundImageView.image = UIImage(named: self.loginBackgroundImageNames[self.loginBackgroundImageIndex])
        })
        var controlsToHide: [UIControl]!
        if fromResetPasswordMode {
            controlsToHide = [self.usernameTextField, self.passwordTextField, self.confirmPasswordTextField]
        } else {
            controlsToHide = self.controlsHiddenOnLogin
        }
        controlsToHide.forEach({ (component: UIControl) in
            UIView.transition(with: component, duration: animationDuration, options: .transitionCrossDissolve, animations: {
                component.isHidden = true
                }, completion: nil)
        })
        UIView.transition(with: self.deltLoadingView, duration: animationDuration, options: .transitionCrossDissolve, animations: {
            self.deltLoadingView.startAnimating()
            self.deltLoadingView.isHidden = false
            }, completion: nil)
    }
    
    // WARNING: Recursive loop could cause stack overflow.
    fileprivate func pulseLoginLabel() {
        UIView.animate(withDuration: 1, animations: {
            self.loginLabel.alpha = 0
        }, completion: { _ in
            UIView.animate(withDuration: 2, animations: {
                self.loginLabel.alpha = 1
                }, completion: { _ in
                    if self.shouldContinueAnimating {
                        self.pulseLoginLabel()
                    }
            })
        }) 
    }
    
    fileprivate func endLoginAnmation(inResetPasswordMode endInResetPasswordMode: Bool) {
        let animationDuration = 0.5
        self.shouldContinueAnimating = false
        
        if endInResetPasswordMode {
            // Use login label to animate to reset password button.
            self.loginLabel.isHidden = false
            self.loginButton.isHidden = true
            UIView.animate(withDuration: animationDuration, animations: {
                self.loginLabel.text = self.resetPasswordString
                self.loginLabel.sizeToFit()
                self.loginLabel.center.x = self.loginView.center.x
                self.loginLabel.center.y = self.loginLabel.center.y + self.textFieldOriginalHeight * 2
            }, completion: { _ in
                self.resetPasswordButton.isHidden = false
                self.loginLabel.isHidden = true
            }) 
            
            [self.usernameTextField, self.passwordTextField].forEach({ (component: UIControl) in
                UIView.transition(with: component, duration: animationDuration, options: .transitionCrossDissolve, animations: {
                    component.isHidden = false
                    }, completion: nil)
            })
            
            self.confirmPasswordTextFieldHeight.constant = self.textFieldOriginalHeight
            self.confirmPasswordTextFieldBottomSpacing.constant = self.textFieldOriginalBottomSpacing
            self.loginView.setNeedsLayout()
            self.confirmPasswordTextField.setNeedsLayout()
            UIView.animate(withDuration: animationDuration, animations: { () -> Void in
                self.loginView.layoutIfNeeded()
                self.confirmPasswordTextField.layoutIfNeeded()
                self.passwordTextField.returnKeyType = .next
            }, completion: { _ in
                UIView.transition(with: self.confirmPasswordTextField, duration: animationDuration, options: .transitionCrossDissolve, animations: {
                    self.confirmPasswordTextField.isHidden = false
                    }, completion: nil)
            }) 
            
        } else {
            // Return duplicate login label to login button title label's position.
            UIView.animate(withDuration: animationDuration, animations: {
                self.loginLabel.text = self.loginString
                self.loginLabel.sizeToFit()
                self.loginLabel.frame.origin.x = self.loginLabelOriginalOrigin.x
                }, completion: { _ in
                    self.loginButton.isHidden = false
                    self.loginLabel.isHidden = true
            })
            self.controlsHiddenOnLogin.forEach({ (component: UIControl) in
                UIView.transition(with: component, duration: animationDuration, options: .transitionCrossDissolve, animations: {
                    component.isHidden = false
                    }, completion: nil)
            })
        }
        
        UIApplication.shared.setStatusBarHidden(false, with: .fade)
        UIView.transition(with: self.backgroundImageView, duration: animationDuration, options: .transitionCrossDissolve, animations: {
            self.backgroundImageView.alpha = 1
            }, completion: nil)
        UIView.transition(with: self.deltLoadingView, duration: animationDuration, options: .transitionCrossDissolve, animations: {
            self.deltLoadingView.isHidden = true
            self.deltLoadingView.stopAnimating()
            }, completion: nil)
        
        self.lastFirstResponder?.becomeFirstResponder()
    }
    
    fileprivate func transitionToApp() {
        let animationDuration = 0.5
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        UIView.transition(with: self.view.window!, duration: animationDuration, options: UIViewAnimationOptions.transitionCrossDissolve, animations: { () -> Void in
            self.view.window!.rootViewController = appDelegate.hamburgerViewController
            let reelStoryboard = UIStoryboard(name: "Reel", bundle: nil)
            let reelNC = reelStoryboard.instantiateViewController(withIdentifier: "ReelNavigationController") as! UINavigationController
            if let reelVC = reelNC.viewControllers[0] as? ReelViewController {
                reelVC.menuDelegate = appDelegate.menuViewController // Set menu delegate so menu button works for first view shown.
            }
            
            appDelegate.hamburgerViewController?.contentViewController = reelNC
            appDelegate.menuViewController?.tableView.reloadData()
            
            }, completion: nil)
    }
}


// MARK: - Text Field Delegate

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField.returnKeyType {
        case .go:
            self.goKeyPressed()
        default:
            textField.nextTextField?.becomeFirstResponder()
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.lastFirstResponder = textField
    }
}


// MARK: - Mail Compose View Controller Delegate

extension LoginViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        // TODO: Handle each mail case? i.e. sent, not sent, etc.
        
        controller.dismiss(animated: true) {
            if result == .sent {
                self.presentUnrecognizedUserSignupRequestSubmittedAlert()
            }
        }
    }
    
    fileprivate func presentUnrecognizedUserSignupRequestMailCompose() {
        if MFMailComposeViewController.canSendMail() {
            let subject = "Signup Request - " + AppDelegate.appName
            let recipient = "thedeltusa@gmail.com"
            var body = "Please sign me up for The Delt:"
            body += "\nName: "
            if let name = self.nameTextField.text {
                body += name
            }
            body += "\nEmail: "
            if let email = self.emailTextField.text {
                body += email
            }
            body += "\nUsername: "
            if let username = self.usernameTextField.text {
                body += username
            }
            body += "\nTheta Delta Chi Charge: "
            
            let mailComposeVC = MFMailComposeViewController()
            mailComposeVC.mailComposeDelegate = self
            mailComposeVC.setSubject(subject)
            mailComposeVC.setToRecipients([recipient])
            mailComposeVC.setMessageBody(body, isHTML: false)
            
            
            // mailComposeVC.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.blackColor()]
            // UINavigationBar.appearance().barStyle = .Black
            
            self.present(mailComposeVC, animated: true, completion: nil)
            
        } else {
            let alert = UIAlertController(title: "Mail Not Enabled", message: "Could not send signup request. Please set up a mail account for your device and try again.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func presentUnrecognizedUserSignupRequestSubmittedAlert() {
        let alert = UIAlertController(title: "Thanks for Signing Up!", message: "If your charge has already been added to The Delt, you'll be added immediately. If your charge is not yet using The Delt, we'll be in touch as soon as possible about signing up your charge.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}


// MARK: - Actions

extension LoginViewController {
    func goKeyPressed() {
        if self.inSignupMode {
            if !resetPasswordButton.isHidden {
                self.resetPasswordButton.sendActions(for: .touchUpInside)
            } else {
                self.signupButton.sendActions(for: .touchUpInside)
            }
        } else {
            self.loginButton.sendActions(for: .touchUpInside)
        }
    }
    
    @IBAction func onLoginButtonTapped(_ sender: Any) {
        if self.inSignupMode {
            self.showSignupMode(false)
        } else {
            if let username = self.usernameTextField.text, let password = self.passwordTextField.text {
                self.logInUser(username, password: password)
            }
        }
    }
    
    @IBAction func signupPressed(_ sender: AnyObject) {
        self.view.endEditing(true)
        if self.inSignupMode {
            if let email = self.emailTextField.text {
                if self.isValidEmail(email) {
                    self.beginSignupRequest(email)
                } else {
                    let alert = UIAlertController(title: "Email Required", message: "Please enter a valid email address.", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                    self.present(alert, animated: true, completion: { _ in
                        self.showSignupMode(false)
                        self.clearTextFields()
                    })
                }
            }
        } else {
            self.showSignupMode(true)
        }
    }
    
    @IBAction func onResetPasswordTapped(_ sender: AnyObject) {
        if let password = self.passwordTextField.text, let confirmPassword = self.confirmPasswordTextField.text {
            if password.characters.count != 0 && confirmPassword.characters.count != 0 {
                if password == confirmPassword {
                    self.startLoginAnimation(fromResetPasswordMode: true)
                    self.resetCurrentUserPassword(password)
                } else {
                    let alert = UIAlertController(title: "Passwords Don't Match", message: "Please try again.", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    @IBAction func onBackgroundTapped(_ sender: AnyObject) {
        self.view.endEditing(true)
        self.lastFirstResponder = nil
    }
}
