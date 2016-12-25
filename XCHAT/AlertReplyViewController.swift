//
//  AlertReplyViewController.swift
//  XCHAT
//
//  Created by Mateo Garcia on 12/24/16.
//  Copyright © 2016 Mateo Garcia. All rights reserved.
//

import UIKit
import MBProgressHUD
import Parse

class AlertReplyViewController: AlertComposeViewController {
    
    @IBOutlet weak var inReplyToLabel: UILabel!
    @IBOutlet weak var replyTextView: CustomTextView!
    
    var alert: PFObject!
    var replyToUser: PFUser!
    
    let kInReplyToPrefix = "In reply to "

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let name = self.replyToUser["name"] as? String {
            self.inReplyToLabel.text = self.kInReplyToPrefix + name
        } else if let username = self.replyToUser.username {
            self.inReplyToLabel.text = self.kInReplyToPrefix +  username
        } else {
            self.inReplyToLabel.isHidden = true
        }
        
        self.replyTextView.placeholder = "What do you have to say?"
        self.replyTextView.placeholderLabel.textColor = UIColor.lightText
        if let username = self.replyToUser.username {
            self.replyTextView.text = "@" + username
            self.replyTextView.placeholderLabel.isHidden = true
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.replyTextView.becomeFirstResponder()
    }
}


// MARK: - Helpers

extension AlertReplyViewController {
    func postReply() {
        
        print("POSTING REPLY")
        
        // User forgets to enter alert subject.
        if self.replyTextView.text == "" {
            let alert = UIAlertController(title: "Empty Reply!", message: "Whatchu tryna say bro.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
        } else {
            let reply = PFObject(className: "AlertReply")
            
            reply["message"] = self.replyTextView.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            reply["author"] = PFUser.current()!
            
            if self.photo != nil {
                let imageData = UIImageJPEGRepresentation(self.photo!, 100)
                let imageFile = PFFile(name: "image.jpeg", data: imageData!)
                alert["image"] = imageFile
                
                if self.video != nil {
                    alert["video"] = self.video
                }
            }
            
            func presentReplyPostErrorAlert() {
                let alertVC = UIAlertController(title: "Unable to Post Reply", message: "Please try again.", preferredStyle: .alert)
                alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alertVC, animated: true, completion: nil)
            }
            
            let currentHUD = MBProgressHUD.showAdded(to: self.view, animated: true)
            currentHUD.label.text = "Posting Reply..."
            reply.saveInBackground { (result: Bool, error: Error?) -> Void in
                if error != nil {
                    currentHUD.hide(animated: true)
                    print(error!.localizedDescription)
                    presentReplyPostErrorAlert()
                } else {
                    let query = PFQuery(className: "Alert")
                    let objectId = self.alert.value(forKey: "objectId") as! String
                    query.getObjectInBackground(withId: objectId) { (alert: PFObject?, error: Error?) -> Void in
                        if error != nil {
                            currentHUD.hide(animated: true)
                            print(error!.localizedDescription)
                            presentReplyPostErrorAlert()
                        } else if let alert = alert {
                            alert.add(reply, forKey: "replies") // Add reply to alert's array of replies.
                            alert.incrementKey("replyCount")
                            alert.saveInBackground(block: { (completed: Bool, eror: Error?) -> Void in
                                if let error = error {
                                    currentHUD.hide(animated: true)
                                    print(error.localizedDescription)
                                    presentReplyPostErrorAlert()
                                } else {
                                    // FIXME: code to refresh conversation list before dismissal.
                                    currentHUD.hide(animated: true)
                                    self.dismiss(animated: true, completion: nil)
                                }
                            })
                        }
                    }
                }
            }
        }
    }
}


// MARK: - Actions

extension AlertReplyViewController {
    @IBAction func onPostButtonTapped(_ sender: Any) {
        self.view.endEditing(true)
        self.postReply()
    }
}
