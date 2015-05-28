//
//  NotificationSettingConstants.swift
//  XCHAT
//
//  Created by Jim Cai on 5/14/15.
//  Copyright (c) 2015 Mateo Garcia. All rights reserved.
//

import Foundation

class NotificationSettingConstants{
    private struct SubStruct { static var staticVariable: [String] = [
        "New threads",
        "New replies",
        "New photos"
        ]
    }
    class var settingsList: [String]
        {
        get { return SubStruct.staticVariable }
        set { SubStruct.staticVariable = newValue }
    }
 
    
}
