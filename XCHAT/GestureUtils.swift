//
//  GestureUtils.swift
//  Slyce
//
//  Created by Mateo Garcia on 12/18/15.
//  Copyright © 2015 com.plusone. All rights reserved.
//

import UIKit

class GestureUtils: NSObject {
    
    class func pointIsWithinFrame(_ point: CGPoint, frame: CGRect) -> Bool {
        let frameX = frame.origin.x
        let frameY = frame.origin.y
        
        let first = point.x >= frameX
        let second = point.y >= frameY
        let third = point.x < frameX + frame.width
        let fourth = point.y < frameY + frame.height
        
        let total = (first && second) && (third && fourth)
        
        return total
    }
}
