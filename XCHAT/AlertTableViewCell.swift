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
    @objc optional func alertTableViewCellShouldReload()
    func alertTableViewCellWasFlagged(withError: Bool)
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
                
                print("SETTING LIKED: \(self.liked)")
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
        }
        self.flagButton.isSelected = self.flagged
    }
}


// MARK: - Helpers

extension AlertTableViewCell {
    func updateLiked(liked: Bool) {
        let query = PFQuery(className: "Alert")
        if let objectId = self.alert?["objectId"] as? String {
            query.getObjectInBackground(withId: objectId) { (alert: PFObject?, error: Error?) -> Void in
                if error != nil {
                    print(error!.localizedDescription)
                } else if let alert = alert {
                    if let username = PFUser.current()?.username {
                        // Increment or decrement fave count accordingly.
                        if liked {
                            alert.add(username, forKey: "favedBy")
                            alert.incrementKey("numFaves")
                        } else {
                            alert.remove(username, forKey: "favedBy")
                            alert.incrementKey("numFaves", byAmount: -1)
                        }
                    }
                    
                    alert.saveInBackground(block: { (completed: Bool, eror: Error?) -> Void in
                        if let error = error {
                            // Log details of the failure
                            print("Error: \(error) \(error.localizedDescription)")
                            
                        } else {
                            self.delegate?.alertTableViewCellShouldReload?()
                        }
                    })
                }
            }
        }
    }
    
    func updateFlagged(flagged: Bool) {
        let query = PFQuery(className: "Alert")
        if let objectId = self.alert?["objectId"] as? String {
            if flagged {
                self.delegate?.alertTableViewCellWasFlagged(withError: false)
            }
            query.getObjectInBackground(withId: objectId) { (alert: PFObject?, error: Error?) -> Void in
                if error != nil {
                    print(error!.localizedDescription)
                } else if let alert = alert {
                    // Mark photo as flagged.
                    alert["flagged"] = flagged
                    
                    print("ALERT FLAGGED: \(alert["flagged"])")
                    
                    // Increment or decrement flag count accordingly.
                    if flagged {
                        alert.incrementKey("numFlags")
                    } else {
                        alert.incrementKey("numFlags", byAmount: -1)
                    }
                    alert.saveInBackground(block: { (completed: Bool, eror: Error?) -> Void in
                        if let error = error {
                            // Log details of the failure
                            print("Error: \(error) \(error.localizedDescription)")
                            
                        } else {
                            self.delegate?.alertTableViewCellShouldReload?()
                        }
                    })
                }
            }
        } else {
            self.delegate?.alertTableViewCellWasFlagged(withError: true)
        }
    }
}


// MARK: - Actions

extension AlertTableViewCell {
    @IBAction func onLikeButtonTapped(_ sender: Any) {
        self.likeButton.isSelected = !self.liked
        self.updateLiked(liked: !self.liked)
    }
    
    @IBAction func onReplyButtonTapped(_ sender: Any) {
        self.delegate?.alertTableViewCell?(didTapReplyToAlert: self.alert)
    }
    
    @IBAction func onFlagButtonTapped(_ sender: Any) {
        self.flagButton.isSelected = !self.flagged
        self.updateFlagged(flagged: !self.flagged)
    }
}
