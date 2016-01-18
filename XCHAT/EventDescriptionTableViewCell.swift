//
//  EventDescriptionTableViewCell.swift
//  XCHAT
//
//  Created by Mateo Garcia on 1/18/16.
//  Copyright © 2016 Mateo Garcia. All rights reserved.
//

import UIKit

protocol NewEventDelegate {
    func onArtworkButtonTapped()
}

class EventDescriptionTableViewCell: UITableViewCell, UITextViewDelegate {
    
    @IBOutlet weak var artworkButton: UIButton!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var descriptionTextViewHeight: NSLayoutConstraint!
    let descriptionTextViewPlaceholder = "Describe."
    let kMaxDescriptionTextViewHeight = CGFloat(150)
    var defaultDescriptionTextViewHeight: CGFloat!
    
    var newEventDelegate: NewEventDelegate?

    override func awakeFromNib() {
        self.descriptionTextView.delegate = self
        self.descriptionTextView.text = self.descriptionTextViewPlaceholder
        self.defaultDescriptionTextViewHeight = self.descriptionTextViewHeight.constant
        
        self.artworkButton.layer.cornerRadius = 2
        self.artworkButton.clipsToBounds = true
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // MARK: - Text View Delegate
    
    func textViewDidBeginEditing(textView: UITextView) {
        if textView.text == self.descriptionTextViewPlaceholder {
            textView.text = ""
        }
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if textView.text == "" {
            textView.text = self.descriptionTextViewPlaceholder
        }
    }
    
    // TODO: Resize table view cell as text view grows.
    
    /*
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            self.descriptionTextViewHeight.constant = min(self.kMaxDescriptionTextViewHeight,  self.descriptionTextViewHeight.constant + textView.font!.lineHeight)
        } else {
            self.descriptionTextViewHeight.constant = min(self.kMaxDescriptionTextViewHeight, self.defaultDescriptionTextViewHeight - self.defaultDescriptionTextViewHeight + self.descriptionTextView.contentSize.height)
        }
        return true
    }
    */
    
    
    // MARK: - Actions
    
    @IBAction func onArtworkButtonTapped(sender: AnyObject) {
        self.newEventDelegate?.onArtworkButtonTapped()
    }

}
