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

class EventDescriptionTableViewCell: UITableViewCell {
    
    @IBOutlet weak var artworkButton: UIButton!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var descriptionTextView: CustomTextView!
    @IBOutlet weak var descriptionTextViewHeight: NSLayoutConstraint!
    
    let kDescriptionTextViewMaxHeight = CGFloat(150)
    
    var defaultDescriptionTextViewHeight: CGFloat!
    
    var newEventDelegate: NewEventDelegate?

    override func awakeFromNib() {
        self.artworkButton.layer.cornerRadius = 2
        self.artworkButton.clipsToBounds = true
        self.artworkButton.imageView?.contentMode = .scaleAspectFill
        
        self.nameTextField.delegate = self
        self.nameTextField.returnKeyType = .next
        self.nameTextField.nextTextField = self.locationTextField
        
        self.locationTextField.delegate = self
        self.locationTextField.returnKeyType = .next
        
        self.descriptionTextView.delegate = self
        self.descriptionTextView.placeholder = "Describe."
        self.defaultDescriptionTextViewHeight = self.descriptionTextViewHeight.constant
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}


// MARK: - Text View Delegate

extension EventDescriptionTableViewCell: UITextViewDelegate {
    
    /*
    // TODO: Resize table view cell as text view grows.
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            self.descriptionTextViewHeight.constant = min(self.kMaxDescriptionTextViewHeight,  self.descriptionTextViewHeight.constant + textView.font!.lineHeight)
        } else {
            self.descriptionTextViewHeight.constant = min(self.kMaxDescriptionTextViewHeight, self.defaultDescriptionTextViewHeight - self.defaultDescriptionTextViewHeight + self.descriptionTextView.contentSize.height)
        }
        return true
    }
    */
}


// MARK: - Text Field Delegate

extension EventDescriptionTableViewCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.locationTextField {
            self.locationTextField.endEditing(true)
        } else {
            textField.nextTextField?.becomeFirstResponder()
        }
        return true
    }
}


// MARK: - Actions

extension EventDescriptionTableViewCell {
    @IBAction func onArtworkButtonTapped(_ sender: AnyObject) {
        self.newEventDelegate?.onArtworkButtonTapped()
    }
}
