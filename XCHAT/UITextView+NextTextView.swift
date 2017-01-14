//
//  UITextView+NextTextView.swift
//  XCHAT
//
//  Created by Mateo Garcia on 12/25/16.
//  Copyright © 2016 Mateo Garcia. All rights reserved.
//

import UIKit

private var kAssociationKeyNextTextView: UInt8 = 0

extension UITextView {
    var nextTextView: UITextView? {
        get {
            return objc_getAssociatedObject(self, &kAssociationKeyNextTextView) as? UITextView
        }
        set(newField) {
            objc_setAssociatedObject(self, &kAssociationKeyNextTextView, newField, .OBJC_ASSOCIATION_RETAIN)
        }
    }
}
