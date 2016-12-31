//
//  ReplyTableViewCell.swift
//  XCHAT
//
//  Created by Mateo Garcia on 12/25/16.
//  Copyright © 2016 Mateo Garcia. All rights reserved.
//

import UIKit
import Parse
import ParseUI

@objc protocol AlertReplyTableViewCellDelegate {
    func alertReplyTableViewCell(updateFavedForReply reply: PFObject?, atIndexPath indexPath: IndexPath, faved: Bool)
    func alertReplyTableViewCell(replyToReply reply: PFObject?)
    func alertReplyTableViewCell(updateFlaggedForReply reply: PFObject?, atIndexPath indexPath: IndexPath, flagged: Bool)
}

class AlertReplyTableViewCell: UITableViewCell {
    
    @IBOutlet weak var profileImageView: ProfileImageView!
    @IBOutlet weak var nameLabel: UsernameLabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var usernameLabel: UsernameLabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var photoImageView: UIImageView!
    
    @IBOutlet weak var faveButton: UIButton!
    @IBOutlet weak var faveCountLabel: UILabel!
    @IBOutlet weak var replyButton: UIButton!
    @IBOutlet weak var flagButton: UIButton!
    
    weak var delegate: AlertReplyTableViewCellDelegate?
    var indexPath: IndexPath!
    var reply: PFObject?
    var faved = false
    var flagged = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.profileImageView.layer.cornerRadius = 3
        self.profileImageView.clipsToBounds = true
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}


// MARK: - Setup

extension AlertReplyTableViewCell {
    func setUpCell(reply: PFObject) {
        self.reply = reply
        
        // Name, username and profile picture.
        if let author = reply["author"] as? PFUser {
            self.profileImageView.user = author
            author.fetchIfNeededInBackground(block: { (fetchedAuthor: PFObject?, error: Error?) in
                if let usableAuthor = fetchedAuthor as? PFUser {
                    if let profilePhoto = usableAuthor["photo"] as? PFFile {
                        let pfImageView = PFImageView()
                        pfImageView.file = profilePhoto
                        pfImageView.load { (image: UIImage?, error: Error?) -> Void in
                            if let error = error {
                                print("Error: \(error) \(error.localizedDescription)")
                            } else {
                                self.profileImageView.image = image
                            }
                        }
                    }
                    self.nameLabel.user = author
                    self.nameLabel.text = author["name"] as? String
                    self.usernameLabel.user = author
                    self.usernameLabel.text = author.username
                }
            })
        }
        
        if let postedAt = reply["createdAt"] as? Date {
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
        
        self.messageLabel.text = reply["message"] as? String
        
        if let photo = reply["photo"] as? PFFile {
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
        
        // Faves.
        if let favedBy = reply["favedBy"] as? [String] {
            if let username = PFUser.current()?.username {
                self.faved = favedBy.contains(username)
            }
        }
        self.faveButton.isSelected = self.faved
        if let faveCount = reply["faveCount"] as? Int {
            if faveCount > 0 {
                self.faveCountLabel.text = String(faveCount)
            } else {
                self.faveCountLabel.text = ""
            }
        } else {
            self.faveCountLabel.text = ""
        }
        
        // Flagged.
        if let flaggedBy = reply["flaggedBy"] as? [String] {
            if let username = PFUser.current()?.username {
                self.flagged = flaggedBy.contains(username)
            }
        }
        self.flagButton.isSelected = self.flagged
    }
}


// MARK: - Actions

extension AlertReplyTableViewCell {
    @IBAction func onFaveButtonTapped(_ sender: Any) {
        if self.faveButton.isSelected == self.faved {
            self.faveButton.isSelected = !self.faved
            self.delegate?.alertReplyTableViewCell(updateFavedForReply: self.reply, atIndexPath: self.indexPath, faved: !self.faved)
        }
    }
    
    @IBAction func onReplyButtonTapped(_ sender: Any) {
        self.delegate?.alertReplyTableViewCell(replyToReply: self.reply)
    }
    
    @IBAction func onFlagButtonTapped(_ sender: Any) {
        if self.flagButton.isSelected == self.flagged {
            self.flagButton.isSelected = !self.flagged
            self.delegate?.alertReplyTableViewCell(updateFlaggedForReply: self.reply, atIndexPath: self.indexPath, flagged: !self.flagged)
        }
    }
}
