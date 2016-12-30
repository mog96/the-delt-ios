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
    @objc optional func alertTableViewCell(updateLikedForAlert alert: PFObject?, atIndexPath indexPath: IndexPath, liked: Bool)
    @objc optional func alertTableViewCell(replyToAlert alert: PFObject?)
    @objc optional func alertTableViewCell(updateFlaggedForAlert alert: PFObject?, flagged: Bool)
}

class AlertTableViewCell: UITableViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var profileImageView: ProfileImageView!
    @IBOutlet weak var nameLabel: UsernameLabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var subjectLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var photoImageView: UIImageView!
    
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var replyButton: UIButton!
    @IBOutlet weak var flagButton: UIButton!
    @IBOutlet weak var likeCountLabel: UILabel!
    @IBOutlet weak var replyCountLabel: UILabel!
    
    weak var delegate: AlertTableViewCellDelegate?
    var indexPath: IndexPath!
    var alert: PFObject?
    var liked = false
    var flagged = false
    
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
    
    override func prepareForReuse() {
        self.liked = false
        self.flagged = false
    }
}


// MARK: - Setup

extension AlertTableViewCell {
    func setUpCell(alert: PFObject) {
        self.alert = alert
        
        // Name and profile picture.
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
        
        // Date.
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
        
        // Subject and message.
        self.subjectLabel.text = alert["subject"] as? String
        self.messageLabel.text = alert["message"] as? String
        
        if let photo = alert["photo"] as? PFFile {
            print("ALERT PHOTO URL:", photo.url)
            
            let pfImageView = PFImageView()
            pfImageView.file = photo
            pfImageView.load { (image: UIImage?, error: Error?) -> Void in
                if let error = error {
                    // Log details of the failure
                    print("Error: \(error) \(error.localizedDescription)")
                    
                } else {
                    self.photoImageView.image = image
                }
            }
        }
        
        // Like.
        if let likedBy = alert["likedBy"] as? [String] {
            if let username = PFUser.current()?.username {
                self.liked = likedBy.contains(username)
                self.likeButton.isSelected = self.liked
            }
        }
        self.likeButton.isSelected = self.liked
        if let likeCount = alert["likeCount"] as? Int {
            self.likeCountLabel.text = String(likeCount)
        } else {
            self.likeCountLabel.text = ""
        }
        
        // Reply count.
        if let replies = alert["replies"] as? [PFObject] {
            self.replyCountLabel.text = String(replies.count)
        } else {
            self.replyCountLabel.text = ""
        }
        
        // Flagged.
        if let flagged = alert["flagged"] as? Bool {
            self.flagged = flagged
            self.flagButton.isSelected = self.flagged
        }
        self.flagButton.isSelected = self.flagged
    }
}


// MARK: - Actions

extension AlertTableViewCell {
    @IBAction func onLikeButtonTapped(_ sender: Any) {
        self.likeButton.isSelected = !self.liked
        self.delegate?.alertTableViewCell?(updateLikedForAlert: self.alert, atIndexPath: self.indexPath, liked: !self.liked)
    }
    
    @IBAction func onReplyButtonTapped(_ sender: Any) {
        self.delegate?.alertTableViewCell?(replyToAlert: self.alert)
    }
    
    @IBAction func onFlagButtonTapped(_ sender: Any) {
        self.flagButton.isSelected = !self.flagged
        self.delegate?.alertTableViewCell?(updateFlaggedForAlert: self.alert, flagged: !self.flagged)
    }
}
