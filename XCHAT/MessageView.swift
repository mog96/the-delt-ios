//
//  MessageView.swift
//  Slyce
//
//  Created by Mateo Garcia on 12/17/15.
//  Copyright © 2015 com.plusone. All rights reserved.
//

import UIKit

@objc
protocol MessageViewDelegate {
    func onSendButtonTapped()
    optional func returned()
}

class MessageView: UIView, UITextViewDelegate {

    @IBOutlet weak var messageViewHeight: NSLayoutConstraint!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var sendButton: UIButton!
    
    weak var delegate: MessageViewDelegate?
    var placeholder = "Holler at your brothers."
    
    var defaultMessageViewHeight: CGFloat!
    let kMaxMessageViewHeight = CGFloat(150)
    var defaultMessageTextViewHeight: CGFloat!
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    override func awakeFromNib() {
        self.messageTextView.delegate = self
        self.messageTextView.returnKeyType = UIReturnKeyType.Done
        self.messageTextView.text = self.placeholder
        
        self.defaultMessageViewHeight = self.messageViewHeight.constant
        self.defaultMessageTextViewHeight = self.messageTextView.frame.height
    }
    
    
    // MARK: - Text View Delegate
    
    func textViewDidBeginEditing(textView: UITextView) {
        if textView.text == self.placeholder {
            textView.text = ""
        }
    }
    

    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            self.messageViewHeight.constant = min(self.kMaxMessageViewHeight,  messageViewHeight.constant + textView.font!.lineHeight)
        } else {
            self.messageViewHeight.constant = min(self.kMaxMessageViewHeight, self.defaultMessageViewHeight - self.defaultMessageTextViewHeight + self.messageTextView.contentSize.height)
        }
        return true
    }
    
    
    // MARK: - Actions
    
    @IBAction func onSendButtonTapped(sender: AnyObject) {
        delegate?.onSendButtonTapped()
        self.messageTextView.text = ""
        self.messageViewHeight.constant = self.defaultMessageViewHeight
    }
    
    
    // MARK: - Helpers
    
    func resetMessageTextView() {
        self.messageViewHeight.constant = self.defaultMessageViewHeight
        if self.messageTextView.text == "" {
            self.messageTextView.text = self.placeholder
        }
    }

}
