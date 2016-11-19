//
//  CustomTextView.swift
//  XCHAT
//
//  Created by Mateo Garcia on 11/18/16.
//  Copyright © 2016 Mateo Garcia. All rights reserved.
//

import UIKit

// Imitates behavior of UITextField, with same placeholder color and placeholder behavior.
class CustomTextView: UITextView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    var placeholderLabel: UILabel!
    var placeholder = "" {
        didSet {
            self.placeholderLabel.text = self.placeholder
            self.placeholderLabel.sizeToFit()
        }
    }
    var placeholderTextColor = LayoutUtils.textFieldPlaceholderTextColor
    
    private var shouldRemovePlaceholderOnTextChange = false
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        self.commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    private func commonInit() {
        self.placeholderLabel = UILabel()
        self.placeholderLabel.font = self.font
        self.placeholderLabel.textColor = self.placeholderTextColor
        self.addSubview(self.placeholderLabel)
        self.placeholderLabel.frame.origin = CGPoint(x: 5, y: self.font!.pointSize / 2 + 1)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.textDidChange), name: UITextViewTextDidChangeNotification, object: self)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.didBeginEditing), name: UITextViewTextDidBeginEditingNotification, object: self)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.didEndEditing), name: UITextViewTextDidEndEditingNotification, object: self)
    }
}


// MARK: - Notification Listeners

extension CustomTextView {
    @objc private func didBeginEditing() {
        self.placeholderLabel.hidden = self.text.characters.count != 0
    }
    
    @objc private func textDidChange() {
        self.placeholderLabel.hidden = self.text.characters.count != 0
    }
    
    @objc private func didEndEditing() {
        self.placeholderLabel.hidden = self.text.characters.count != 0
    }
}

//extension CustomTextView: UITextViewDelegate {
//    func shouldChangeTextInRange(range: UITextRange, replacementText text: String) -> Bool {
//        print("RANGE:", range)
//        return true
//    }
//}
