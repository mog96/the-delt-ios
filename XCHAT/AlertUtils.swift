//
//  AlertUtils.swift
//  XCHAT
//
//  Created by Mateo Garcia on 12/30/16.
//  Copyright © 2016 Mateo Garcia. All rights reserved.
//

import Foundation
import Parse

class AlertUtils {
    class func updateFaved(forAlert alert: PFObject, faved: Bool, completion: ((PFObject?, Error?) -> ())?) {
        let query = PFQuery(className: "Alert")
        if let objectId = alert.objectId {
            query.getObjectInBackground(withId: objectId) { (fetchedAlert: PFObject?, error: Error?) -> Void in
                if error != nil {
                    print(error!.localizedDescription)
                } else if let updatedAlert = fetchedAlert {
                    if let username = PFUser.current()?.username {
                        // Increment or decrement fave count accordingly.
                        if faved {
                            updatedAlert.addUniqueObject(username, forKey: "favedBy")
                            updatedAlert.incrementKey("faveCount")
                        } else {
                            updatedAlert.remove(username, forKey: "favedBy")
                            updatedAlert.incrementKey("faveCount", byAmount: -1)
                        }
                    }
                    updatedAlert.saveInBackground(block: { (completed: Bool, error: Error?) -> Void in
                        completion?(updatedAlert, error)
                    })
                }
            }
        }
    }
    
    class func updateFlagged(forAlert alert: PFObject, flagged: Bool, completion: ((PFObject?, Error?) -> ())?) {
        let query = PFQuery(className: "Alert")
        if let objectId = alert.objectId {
            query.getObjectInBackground(withId: objectId) { (fetchedAlert: PFObject?, error: Error?) -> Void in
                if error != nil {
                    print(error!.localizedDescription)
                } else if let updatedAlert = fetchedAlert {
                    if let username = PFUser.current()?.username {
                        // Increment or decrement flag count accordingly.
                        if flagged {
                            updatedAlert.addUniqueObject(username, forKey: "flaggedBy")
                            updatedAlert.incrementKey("flagCount")
                        } else {
                            updatedAlert.remove(username, forKey: "flaggedBy")
                            updatedAlert.incrementKey("flagCount", byAmount: -1)
                        }
                    }
                    updatedAlert.saveInBackground(block: { (completed: Bool, error: Error?) -> Void in
                        completion?(updatedAlert, error)
                    })
                }
            }
        }
    }
}
