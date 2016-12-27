//
//  AlertTableViewCell.swift
//  XCHAT
//
//  Created by Mateo Garcia on 12/23/16.
//  Copyright © 2016 Mateo Garcia. All rights reserved.
//

import UIKit
import Parse
import ParseUI

@objc protocol AlertTableViewCellDelegate {
    @objc optional func alertTableViewCell(didTapReplyToAlert alert: PFObject?)
    
    // TODO: COMPLETE PROCOTOLS AND ACTIONS
}

class AlertTableViewCell: UITableViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var profileImageView: ProfileImageView!
    @IBOutlet weak var nameLabel: UsernameLabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var subjectLabel: UILabel!
    // @IBOutlet weak var subjectLabelHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var messageLabel: UILabel!
    // @IBOutlet weak var messageLabelHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var replyButton: UIButton!
    @IBOutlet weak var flagButton: UIButton!
    
    weak var delegate: AlertTableViewCellDelegate?
    
    var alert: PFObject?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.containerView.layer.cornerRadius = 4
        self.containerView.clipsToBounds = true
        self.profileImageView.layer.cornerRadius = 3
        self.profileImageView.clipsToBounds = true
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setUpCell(alert: PFObject) {
        self.alert = alert
        if let author = alert["author"] as? PFUser {
            self.profileImageView.user = author
            if let _ = author.value(forKey: "photo") {
                let pfImageView = PFImageView()
                pfImageView.file = author.value(forKey: "photo") as? PFFile
                pfImageView.load { (image: UIImage?, error: Error?) -> Void in
                    if let error = error {
                        // Log details of the failure
                        print("Error: \(error) \(error.localizedDescription)")
                        
                    } else {
                        self.profileImageView.image = image
                    }
                }
            }
            
            self.nameLabel.user = author
            self.nameLabel.text = author["name"] as? String
        }
        
        if let postedAt = alert["createdAt"] as? Date {
            let dateFormatter = DateFormatter()
            let calendar = Calendar.current
            //        dateFormatter.dateFormat = "M/d"
            //        self.dateLabel.text = dateFormatter.string(from: postedAt)
            
            dateFormatter.amSymbol = "a"
            dateFormatter.pmSymbol = "p"
            var comp = (calendar as NSCalendar).components([.hour, .minute], from: postedAt)
            dateFormatter.dateFormat = "M/d h:mma"
            if comp.minute == 0 {
                dateFormatter.dateFormat = "ha"
            }
            self.dateLabel.text = dateFormatter.string(from: postedAt)
        }
        
        self.subjectLabel.text = alert["subject"] as? String
        self.messageLabel.text = alert["message"] as? String
    }
}


// MARK: - Actions

extension AlertTableViewCell {
    @IBAction func onLikeButtonTapped(_ sender: Any) {
    }
    
    @IBAction func onReplyButtonTapped(_ sender: Any) {
        self.delegate?.alertTableViewCell?(didTapReplyToAlert: self.alert)
    }
    
    @IBAction func onFlagButtonTapped(_ sender: Any) {
    }
}
