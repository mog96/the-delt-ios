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

class ShareViewController: SLComposeServiceViewController {
    
    var selectedImageURL: NSURL!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let username = NSUserDefaults(suiteName: "group.com.tdx.thedelt")?.objectForKey("Username") as? String {
            UploadImageService.sharedService.username = username
        } else {
            let alert = UIAlertController(title: "Error", message: "No current user found. Please go to 'the delt.' and log in.", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: { _ in
                self.dismissViewControllerAnimated(true, completion: nil)
            }))
            self.presentViewController(alert, animated: true, completion: nil)
        }
        
        let content = self.extensionContext!.inputItems[0] as! NSExtensionItem
        let contentTypeImage = kUTTypeImage as String
        for attatchment in content.attachments as! [NSItemProvider] {
            if attatchment.hasItemConformingToTypeIdentifier(contentTypeImage) {
                attatchment.loadItemForTypeIdentifier(contentTypeImage, options: nil, completionHandler: { (data: NSSecureCoding?, error: NSError!) in
                    if error == nil {
                        if let url = data as? NSURL {
                            self.selectedImageURL = url
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

    override func isContentValid() -> Bool {
        if self.selectedImageURL != nil {
            return true
        }
        return false
    }

    override func didSelectPost() {
        UploadImageService.sharedService.uploadImage(self.selectedImageURL, caption: self.contentText)
        self.extensionContext!.completeRequestReturningItems([], completionHandler: nil)
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
