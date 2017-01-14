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

@objc protocol AlertReplyViewControllerDelegate {
    @objc optional func alertReplyViewController(didSaveNewEvent event: PFObject)
}

class AlertReplyViewController: AlertComposeViewController {
    
    @IBOutlet weak var inReplyToLabel: UILabel!
    @IBOutlet weak var replyTextView: CustomTextView!
    
    var replyToAlert: PFObject!
    var replyToReply: PFObject?
    var additionalTag: String?
    let kInReplyToPrefix = "In reply to "

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.replyTextView.placeholder = "What do you have to say?"
        self.replyTextView.placeholderLabel.textColor = UIColor.lightText
        
        let replyToReplyAuthor = self.replyToReply?["author"] as? PFUser
        let replyToUser = self.replyToAlert["author"] as? PFUser
        
        var replyingToReplyAuthor = false
        
        // If replying to a reply, add information of author of said reply.
        if replyToReplyAuthor != nil && (replyToUser == nil || replyToReplyAuthor!.objectId != replyToUser!.objectId) {
            replyingToReplyAuthor = true
            if let name = replyToReplyAuthor!["name"] as? String {
                self.inReplyToLabel.text = self.kInReplyToPrefix + name
            } else if let username = replyToReplyAuthor!.username {
                self.inReplyToLabel.text = self.kInReplyToPrefix + "@" + username
            } else {
                self.inReplyToLabel.isHidden = true
            }
            if let username = replyToReplyAuthor!.username {
                self.replyTextView.text = self.replyTextView.text + "@" + username + " "
                self.replyTextView.placeholderLabel.isHidden = true
            }
        } else if replyToUser != nil {
            if let name = replyToUser!["name"] as? String {
                self.inReplyToLabel.text = self.kInReplyToPrefix + name
            } else if let username = replyToUser!.username {
                self.inReplyToLabel.text = self.kInReplyToPrefix + "@" + username
            } else {
                self.inReplyToLabel.isHidden = true
            }
        }
        if let username = replyToUser!.username {
            let placeholder = "@" + username + " "
            if replyingToReplyAuthor {
                self.additionalTag = placeholder
            }
            self.replyTextView.text = self.replyTextView.text + placeholder
            self.replyTextView.placeholderLabel.isHidden = true
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.replyTextView.becomeFirstResponder()
        if self.additionalTag != nil {
            let rangeOfTag = (self.replyTextView.text as NSString).range(of: self.additionalTag!)
            self.replyTextView.selectedRange = rangeOfTag
        }
    }
}


// MARK: - Helpers

extension AlertReplyViewController {
    func postReply() {
        
        print("POSTING REPLY")
        
        // User forgets to enter alert subject.
        if self.replyTextView.text == "" {
            let alert = UIAlertController(title: "Empty Reply!", message: "Whatcha tryna say bro.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
        } else {
            let reply = PFObject(className: "AlertReply")
            
            reply["alert"] = self.replyToAlert
            reply["message"] = self.replyTextView.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            reply["author"] = PFUser.current()!
            if self.photo != nil {
                let imageData = UIImageJPEGRepresentation(self.photo!, 100)
                let imageFile = PFFile(name: "image.jpeg", data: imageData!)
                reply["photo"] = imageFile
                
                if self.video != nil {
                    reply["video"] = self.video
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
                    func completion() {
                        currentHUD.hide(animated: true)
                        self.dismiss(animated: true, completion: nil)
                    }
                    var executed = false
                    self.delegate?.refreshData?(savedObject: reply) {
                        completion()
                        executed = true
                    }
                    if !executed {
                        self.delegate?.refreshData? {
                            completion()
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
