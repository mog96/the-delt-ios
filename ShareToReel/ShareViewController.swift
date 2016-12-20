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
import MBProgressHUD

class ShareViewController: SLComposeServiceViewController {
    
    var selectedImage: UIImage!
    var username: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !Parse.isLocalDatastoreEnabled() {
            let keys = NSDictionary(contentsOfFile: Bundle.main.path(forResource: "Keys", ofType: "plist")!)!
            // Parse config.
            Parse.enableDataSharing(withApplicationGroupIdentifier: "group.com.tdx.thedelt", containingApplication: "com.tdx.thedelt")
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
            Parse.initialize(with: configuration)
            
            PFUser.enableRevocableSessionInBackground(block: { (error: Error?) in
                print("enableRevocableSessionInBackgroundWithBlock completion")
                if error != nil {
                    print("Error enableRevocableSessionInBackgroundWithBlock:", error as Any)
                }
            })
        }
        
        print("CURRENT USER:", PFUser.current()?.username)
        
        if let username = PFUser.current()?.username {
            self.username = username
        } else if let cachedUsername = UserDefaults(suiteName: "group.com.tdx.thedelt")?.object(forKey: "Username") as? String {
            self.username = cachedUsername
        }
        
        print("USERNAME", self.username)
        
        let content = self.extensionContext!.inputItems[0] as! NSExtensionItem
        let contentTypeImage = kUTTypeImage as String
        for attachment in content.attachments as! [NSItemProvider] {
            if attachment.hasItemConformingToTypeIdentifier(contentTypeImage) {
                attachment.loadItem(forTypeIdentifier: contentTypeImage, options: nil, completionHandler: { (data: NSSecureCoding?, error: Error!) in
                    if error == nil {
                        if let url = data as? URL {
                            if let imageData = try? Data(contentsOf: url) {
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
                // attatchment.loadItem(forTypeIdentifier: contentTypeImage, options: nil, completionHandler: )
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if self.username == nil {
            let alert = UIAlertController(title: "Unable to Post", message: "Please go to 'the delt.' and log in.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { _ in
                self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }

    override func isContentValid() -> Bool {
        if self.selectedImage != nil && self.username != nil {
            return true
        }
        return false
    }

    override func didSelectPost() {
        let currentHUD = MBProgressHUD.showAdded(to: self.view, animated: true)
        currentHUD.label.text = "Uploading..."
        
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
        photo.saveInBackground(block: { (completed: Bool, error: Error?) -> Void in
            if let error = error {
                // Log details of the failure
                print("Error: \(error)")
                
            } else {
                currentHUD.hide(animated: true)
                print("UPLOADED IMAGE FROM SHARE EXTENSION")
                self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
            }
        })
    }

    override func configurationItems() -> [Any]! {
        // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
        return []
    }

}


extension ShareViewController {
    func presentLoadImageError() {
        let alert = UIAlertController(title: "Error", message: "Unable to load image.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { _ in
            self.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
}
