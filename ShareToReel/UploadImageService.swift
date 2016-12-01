//
//  UploadImageService.swift
//  ShareToReel
//
//  Created by Joyce Echessa on 3/29/15.
//  Copyright (c) 2015 Appcoda. All rights reserved.
//

import Foundation
import UIKit

public class UploadImageService: NSObject {
    
    var baseURL: String!
    private var applicationID: String!
    private var restAPIKey: String!
    var username: String!
    private var completionCallbacks: Dictionary<NSURLSessionTask, (NSError?) -> ()> = Dictionary()
    
    public class var sharedService: UploadImageService {
        struct Singleton {
            static let instance = UploadImageService()
        }
        return Singleton.instance
    }
    
    private override init() {
        super.init()
        
        /*
        /* DEVELOPMENT ONLY */
        #if TARGET_IPHONE_SIMULATOR
            self.baseURL = "https://localhost:1337/parse"
        #else
            self.baseURL = "https://mog.local:1337/parse"
        #endif
        /* END DEVELOPMENT ONLY */
        */
 
        self.baseURL = "https://thedelt.herokuapp.com/parse"
        
        guard let keys = NSDictionary(contentsOfFile: NSBundle.mainBundle().pathForResource("Keys", ofType: "plist")!) else {
            print("Upload Error: Unable to load Keys.plist.")
            return
        }
        self.applicationID = keys["ParseApplicationID"] as! String
        self.restAPIKey = keys["ParseRESTAPIKey"] as! String
    }
    
    public func uploadImage(imageURL: NSURL, caption: String) {
        let sessionConfig = NSURLSessionConfiguration.backgroundSessionConfigurationWithIdentifier("com.tdx.thedelt.backgroundsession")
        sessionConfig.sharedContainerIdentifier = "group.com.tdx.thedelt"
        sessionConfig.HTTPAdditionalHeaders = ["X-Parse-Application-Id": applicationID, "X-Parse-REST-API-Key": restAPIKey, "Content-Type": "image/jpeg"]
        
        let session = NSURLSession(configuration: sessionConfig, delegate: self, delegateQueue: NSOperationQueue.mainQueue())
        let url = NSURL(string: self.baseURL + "/files/image.jpeg")!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        
        let task = session.uploadTaskWithRequest(request, fromFile: imageURL)
        task.resume()
    }
    
    /*
    private func tempContainerURL(image: UIImage, name: String) -> NSURL? {
        if let containerURL = NSFileManager.defaultManager().containerURLForSecurityApplicationGroupIdentifier("group.com.appcoda.ImgurShare") {
            var contairURLWithName = containerURL.URLByAppendingPathComponent(name)
            if !NSFileManager.defaultManager().fileExistsAtPath(contairURLWithName!.path!) {
                do {
                    try NSFileManager.defaultManager().createDirectoryAtPath(containerURL.path!, withIntermediateDirectories: false, attributes: nil)
                } catch {
                    print("ERROR GETTING FILE PATH")
                }
            }
            
            var imageDirectoryURL = containerURL
            imageDirectoryURL = imageDirectoryURL.URLByAppendingPathComponent(name)!
            imageDirectoryURL = imageDirectoryURL.URLByAppendingPathExtension("jpg")!
            let imageData = UIImageJPEGRepresentation(image, 1.0)
            let saved = imageData!.writeToFile(imageDirectoryURL.path!, atomically: true)
            return imageDirectoryURL
        } else {
            return nil
        }
    }
    */
}


// MARK - NSURLSessionTaskDelegate

extension UploadImageService: NSURLSessionDataDelegate, NSURLSessionTaskDelegate {
    public func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        
        print("TASK COMPLETED")
        
        if let completionCallback = completionCallbacks[task] {
            completionCallbacks.removeValueForKey(task)
            completionCallback(error)
        }
    }
    
    public func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveData data: NSData) {
        if let completionBlock = completionCallbacks[dataTask] {
            var error: NSError?
            
            print("BANANA")
            
            if error == nil {
                let response = JSON(data: data)
                print("RECEIVED JSON DATA: \(response)")
            } else {
                print("ERROR:", error?.userInfo["error"])
            }
            completionBlock(error)
            
            /*
            let sessionConfig = NSURLSessionConfiguration.defaultSessionConfiguration()
            sessionConfig.sharedContainerIdentifier = "group.com.tdx.thedelt"
            sessionConfig.HTTPAdditionalHeaders = ["X-Parse-Application-Id": applicationID, "X-Parse-REST-API-Key": restAPIKey, "Content-Type": "application/json"]
            
            var object: JSON = ["username": self.username, "faved": false, "numFaves": 0, "flagged": false, "numFlags": 0]
            if caption.characters.count > 0 {
                object["comments"] = [[self.username, caption]]
                object["numComments"] = 1
            } else {
                object["numComments"] = 0
            }
            
            let session = NSURLSession(configuration: sessionConfig, delegate: UploadImageService.sharedService, delegateQueue: NSOperationQueue.mainQueue())
            
            let url = NSURL(string: self.baseURL + "/1/classes/Photo")!
            let request = NSMutableURLRequest(URL: url)
            request.HTTPMethod = "POST"
            
            // TODO: READ FILE URL FROM RETURNED DATA
            let task = session.uploadTaskWithRequest(request, fromFile: imageURL)
            self.completionCallbacks[task] = { (error: NSError?) in
                if error == nil {
                    /////
                    
                } else {
                    print("ERROR:", error?.userInfo["error"])
                }
            }
            task.resume()
            */
        }
    }
}
