//
//  ShareViewController.swift
//  ShareToReel
//
//  Created by Mateo Garcia on 11/30/16.
//  Copyright © 2016 Mateo Garcia. All rights reserved.
//

import UIKit
import Social
import MobileCoreServices
import Parse

class ShareViewController: SLComposeServiceViewController {
    
    var selectedImage: UIImage!
    var username: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !Parse.isLocalDatastoreEnabled() {
            let keys = NSDictionary(contentsOfFile: NSBundle.mainBundle().pathForResource("Keys", ofType: "plist")!)!
            // Parse config.
            Parse.enableDataSharingWithApplicationGroupIdentifier("group.com.tdx.thedelt", containingApplication: "com.tdx.thedelt")
            Parse.enableLocalDatastore()
            let configuration = ParseClientConfiguration {
                $0.applicationId = keys["ParseApplicationID"] as? String
                $0.clientKey = keys["ParseClientKey"] as? String
                
                // /*
                /* DEVELOPMENT ONLY */
                #if TARGET_IPHONE_SIMULATOR
                    $0.server = "http://localhost:1337/parse"
                #else
                    $0.server = "http://mog.local:1337/parse"
                #endif
                /* END DEVELOPMENT ONLY */
                // */
                
                $0.server = "https://thedelt.herokuapp.com/parse"
            }
            Parse.initializeWithConfiguration(configuration)
            
            PFUser.enableRevocableSessionInBackgroundWithBlock { (error: NSError?) -> Void in
                print("enableRevocableSessionInBackgroundWithBlock completion")
            }
        }
        
        print("CURRENT USER:", PFUser.currentUser()?.username)
        
        if let username = PFUser.currentUser()?.username {
            self.username = username
        } else if let cachedUsername = NSUserDefaults(suiteName: "group.com.tdx.thedelt")?.objectForKey("Username") as? String {
            self.username = cachedUsername
        }
        
        print("USERNAME", self.username)
        
        let content = self.extensionContext!.inputItems[0] as! NSExtensionItem
        let contentTypeImage = kUTTypeImage as String
        for attatchment in content.attachments as! [NSItemProvider] {
            if attatchment.hasItemConformingToTypeIdentifier(contentTypeImage) {
                attatchment.loadItemForTypeIdentifier(contentTypeImage, options: nil, completionHandler: { (data: NSSecureCoding?, error: NSError!) in
                    if error == nil {
                        if let url = data as? NSURL {
                            if let imageData = NSData(contentsOfURL: url) {
                                self.selectedImage = UIImage(data: imageData)
                            } else {
                                self.presentLoadImageError()
                            }
                        } else {
                            self.presentLoadImageError()
                        }
                    } else {
                        self.presentLoadImageError()
                    }
                })
            }
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if self.username == nil {
            let alert = UIAlertController(title: "Unable to Post", message: "Please go to 'the delt.' and log in.", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: { _ in
                self.extensionContext!.completeRequestReturningItems([], completionHandler: nil)
            }))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }

    override func isContentValid() -> Bool {
        if self.selectedImage != nil && self.username != nil {
            return true
        }
        return false
    }

    override func didSelectPost() {
        guard self.username != nil else {
            return
        }
        
        let photo = PFObject(className: "Photo")
        
        let imageData = UIImageJPEGRepresentation(self.selectedImage!, 100)
        let imageFile = PFFile(name: "image.jpeg", data: imageData!)
        photo["imageFile"] = imageFile
        
        /*
        if let _ = self.uploadVideo {
            photo["videoFile"] = self.uploadVideo
        }
        */
        
        photo["username"] = self.username!
        photo["faved"] = false
        photo["numFaves"] = 0
        photo["flagged"] = false
        photo["numFlags"] = 0
        
        var comments = [[String]]()
        if self.contentText.characters.count > 0 {
            photo["numComments"] = 1
            
            comments.append([self.username!, self.contentText])
        } else {
            photo["numComments"] = 0
        }
        photo["comments"] = comments
        photo.saveInBackgroundWithBlock({ (completed: Bool, error: NSError?) -> Void in
            if let error = error {
                // Log details of the failure
                print("Error: \(error) \(error.userInfo)")
                
            } else {
                print("UPLOADED IMAGE FROM SHARE EXTENSION")
                self.extensionContext!.completeRequestReturningItems([], completionHandler: nil)
            }
        })
    }

    func configurationItems() -> [Any]! {
        // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
        return []
    }

}


extension ShareViewController {
    func presentLoadImageError() {
        let alert = UIAlertController(title: "Error", message: "Unable to load image.", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: { _ in
            self.dismissViewControllerAnimated(true, completion: nil)
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }
}
