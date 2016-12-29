//
//  NewAlertViewController.swift
//  XCHAT
//
//  Created by Mateo Garcia on 12/23/16.
//  Copyright © 2016 Mateo Garcia. All rights reserved.
//

import UIKit
import MBProgressHUD
import MediaPlayer
import MobileCoreServices
import Parse

class NewAlertViewController: AlertComposeViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var subjectTextView: CustomTextView!
    @IBOutlet weak var messageTextView: CustomTextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.subjectTextView.placeholder = "Subject"
        self.subjectTextView.placeholderLabel.textColor = UIColor.lightText
        self.subjectTextView.nextTextView = self.messageTextView
        
        self.messageTextView.placeholder = "Message"
        self.messageTextView.placeholderLabel.textColor = UIColor.lightText
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.subjectTextView.becomeFirstResponder()
        
        let containerViewHeight = UIScreen.main.bounds.height - self.navigationController!.navigationBar.frame.height
        self.containerView.frame.size = CGSize(width: self.containerView.frame.width, height: containerViewHeight)
    }
}


// MARK: - Helpers

extension NewAlertViewController {
    func postAlert() {
        print("POSTING")
        
        // User forgets to enter alert subject.
        if self.subjectTextView.text == "" {
            let alert = UIAlertController(title: "Add Alert Subject", message: "Whatchu tryna say bro.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
        } else {
            let alert = PFObject(className: "Alert")
            
            alert["subject"] = self.subjectTextView.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            if self.messageTextView.text.characters.count > 0 {
                alert["message"] = self.messageTextView.text
            }
            alert["author"] = PFUser.current()!
            
            if self.photo != nil {
                let imageData = UIImageJPEGRepresentation(self.photo!, 100)
                let imageFile = PFFile(name: "image.jpeg", data: imageData!)
                alert["photo"] = imageFile
                
                if self.video != nil {
                    alert["video"] = self.video
                }
            }
            
            let currentHUD = MBProgressHUD.showAdded(to: self.view, animated: true)
            currentHUD.label.text = "Posting Alert..."
            alert.saveInBackground { (result: Bool, error: Error?) -> Void in
                if error != nil {
                    currentHUD.hide(animated: true)
                    print(error!.localizedDescription)
                    let alertVC = UIAlertController(title: "Unable to Post Alert", message: "Please try again.", preferredStyle: .alert)
                    alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alertVC, animated: true, completion: nil)
                } else {
                    self.delegate?.refreshData(completion: {
                        currentHUD.hide(animated: true)
                        self.dismiss(animated: true, completion: nil)
                    })
                }
            }
        }
    }
}


// MARK: - Actions

extension NewAlertViewController {
    @IBAction func onPostButtonTapped(_ sender: Any) {
        self.view.endEditing(true)
        self.postAlert()
    }
}
