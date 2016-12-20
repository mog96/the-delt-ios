//
//  UITextField+NextField.swift
//  XCHAT
//
//  Created by Mateo Garcia on 9/12/16.
//  Copyright © 2016 Mateo Garcia. All rights reserved.
//

import UIKit

private var kAssociationKeyNextField: UInt8 = 0

extension UITextField {
    var nextTextField: UITextField? {
        get {
            return objc_getAssociatedObject(self, &kAssociationKeyNextField) as? UITextField
        }
        set(newField) {
            objc_setAssociatedObject(self, &kAssociationKeyNextField, newField, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    internal func resizeText() {
        if let text = self.text{
            self.font = UIFont.systemFont(ofSize: 14)
            let textString = text as NSString
            var widthOfText = textString.size(attributes: [NSFontAttributeName : self.font!]).width
            var widthOfFrame = self.frame.size.width
            // decrease font size until it fits
            while widthOfFrame - 5 < widthOfText {
                let fontSize = self.font!.pointSize
                self.font = self.font?.withSize(fontSize - 0.5)
                widthOfText = textString.size(attributes: [NSFontAttributeName : self.font!]).width
                widthOfFrame = self.frame.size.width
            }
        }
    }
}
