//
//  PushHelper.swift
//  XCHAT
//
//  Created by Jim Cai on 5/13/15.
//  Copyright (c) 2015 Mateo Garcia. All rights reserved.
//

import Foundation
import Parse

class PushHelper{
    
    class func subscribeToChannel(channel:NSString){
        //Subscribe
        // When users indicate they are Giants fans, we subscribe them to that channel.
        let currentInstallation = PFInstallation.currentInstallation()
        currentInstallation?.addUniqueObject("Giants", forKey: "channels")
        
        currentInstallation?.saveInBackgroundWithBlock({ (success:Bool, error:NSError?) -> Void in
            // nothing
        })
    }
    
    class func unsubscribeFromChannel(channel:NSString){
        //Unsubscribe
        // When users indicate they are Giants fans, we subscribe them to that channel.
        let currentInstallation = PFInstallation.currentInstallation()
        currentInstallation?.removeObject("Giants" ,forKey: "channels")
        currentInstallation?.saveInBackgroundWithBlock({ (success:Bool, error:NSError?) -> Void in
            // nothing
        })
    }
    
    class func subscribedChannels() -> [String] {
        return PFInstallation.currentInstallation()!.channels!
    }
    
    func pushToChannel(message: NSString, channel:NSString){
        let push = PFPush()
        push.setChannel(channel as String)
        push.setMessage(message as String)
        push.sendPushInBackgroundWithBlock { (success:Bool, error:NSError?) -> Void in
        }
    }
    
    class func pushToChannels(message: NSString, channels:[String]){
        let push = PFPush()
        push.setChannels(channels)
        push.setMessage(message as String)
        push.sendPushInBackgroundWithBlock { (success:Bool, error:NSError?) -> Void in
            //
        }
    }

}
