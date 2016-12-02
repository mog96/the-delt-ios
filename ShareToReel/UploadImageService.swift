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
    private var completionCallbacks: Dictionary<NSURLSessionTask, (NSURL?, NSError?, NSURL?) -> ()> = Dictionary()
    
    var containerURL: NSURL!
    
    public class var sharedService: UploadImageService {
        struct Singleton {
            static let instance = UploadImageService()
        }
        return Singleton.instance
    }
    
    private override init() {
        super.init()
        
        // /*
        /* DEVELOPMENT ONLY */
        #if TARGET_IPHONE_SIMULATOR
            self.baseURL = "https://localhost:1337/parse"
        #else
            self.baseURL = "https://mog.local:1337/parse"
        #endif
        /* END DEVELOPMENT ONLY */
        // */
 
        // self.baseURL = "https://thedelt.herokuapp.com/parse"
        
        guard let keys = NSDictionary(contentsOfFile: NSBundle.mainBundle().pathForResource("Keys", ofType: "plist")!) else {
            print("Upload Error: Unable to load Keys.plist.")
            return
        }
        self.applicationID = keys["ParseApplicationID"] as! String
        self.restAPIKey = keys["ParseRESTAPIKey"] as! String
    }
    
    public func uploadImage(image: UIImage, caption: String) {
        let sessionConfig = NSURLSessionConfiguration.backgroundSessionConfigurationWithIdentifier("com.tdx.thedelt.backgroundsession")
        sessionConfig.sharedContainerIdentifier = "group.com.tdx.thedelt"
        sessionConfig.HTTPAdditionalHeaders = ["X-Parse-Application-Id": applicationID, "X-Parse-REST-API-Key": restAPIKey, "Content-Type": "image/jpeg"]
        
        let session = NSURLSession(configuration: sessionConfig, delegate: UploadImageService.sharedService, delegateQueue: NSOperationQueue.mainQueue())
        let url = NSURL(string: self.baseURL + "/files/image.jpeg")!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        
//        let task = session.uploadTaskWithRequest(request, fromFile: imageURL)
//        task.resume()
        
        let completionBlock = { (fileURL: NSURL?, error: NSError?, tempContainerURL: NSURL?) in
            if error == nil {
                let sessionConfig = NSURLSessionConfiguration.defaultSessionConfiguration()
                sessionConfig.sharedContainerIdentifier = "group.com.tdx.thedelt"
                sessionConfig.HTTPAdditionalHeaders = ["X-Parse-Application-Id": self.applicationID, "X-Parse-REST-API-Key": self.restAPIKey, "Content-Type": "application/json"]
                
                var object: JSON = ["username": self.username, "faved": false, "numFaves": 0, "flagged": false, "numFlags": 0]
                if caption.characters.count > 0 {
                    object["comments"] = [[self.username, caption]]
                    object["numComments"] = 1
                } else {
                    object["numComments"] = 0
                }
                
                // TODO: SET FILE URL (FILE NAME PORTION ONLY)
                
                let session = NSURLSession(configuration: sessionConfig, delegate: UploadImageService.sharedService, delegateQueue: NSOperationQueue.mainQueue())
                
                let url = NSURL(string: self.baseURL + "/1/classes/Photo")!
                let request = NSMutableURLRequest(URL: url)
                request.HTTPMethod = "POST"
                
                let task = session.dataTaskWithRequest(request)
                /*
                self.completionCallbacks[task] = { (error: NSError?) in
                    if error == nil {
                        /////
                        
                    } else {
                        print("ERROR:", error?.userInfo["error"])
                    }
                }
                */
                task.resume()
                
            } else {
                print("FILE UPLOAD ERROR:", error?.userInfo["error"])
            }
        }
        
        let uuid = NSUUID().UUIDString
        if let tempContainerURL = self.tempContainerURL(image, name: uuid) {
            let task = session.uploadTaskWithRequest(request, fromFile: tempContainerURL)
            completionCallbacks[task] = completionBlock
            
            task.resume()
        } else {
            let error = NSError(domain: "com.tdx.thedelt.uploadservice", code: 1, userInfo: nil)
            completionBlock(nil, error, nil)
        }
    }
    
    private func tempContainerURL(image: UIImage, name: String) -> NSURL? {
        if let containerURL = NSFileManager.defaultManager().containerURLForSecurityApplicationGroupIdentifier("group.com.tdx.thedelt") {
            var containerURLWithName = containerURL.URLByAppendingPathComponent(name)
            if !NSFileManager.defaultManager().fileExistsAtPath(containerURLWithName!.path!) {
                do {
                    try NSFileManager.defaultManager().createDirectoryAtPath(containerURL.path!, withIntermediateDirectories: false, attributes: nil)
                } catch let error as NSError {
                    print("UNABLE TO CREATE DIRECTORY:", error.debugDescription)
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
}


// MARK - NSURLSessionTaskDelegate

extension UploadImageService: NSURLSessionDataDelegate, NSURLSessionTaskDelegate {
    public func URLSessionDidFinishEventsForBackgroundURLSession(session: NSURLSession) {
        print("LALALALA")
    }
    
    public func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        
        print("TASK COMPLETED")
        
        if let completionCallback = completionCallbacks[task] {
            completionCallbacks.removeValueForKey(task)
            completionCallback(nil, error, self.containerURL)
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
            
            // TODO: PASS FILE URL
            
            completionBlock(nil, error, self.containerURL)
        }
    }
}
