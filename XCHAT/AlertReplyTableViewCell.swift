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
    @objc optional func alertReplyTableViewCellDidTapReply()
    @objc optional func alertReplyTableViewCellShouldReload()
}

class AlertReplyTableViewCell: UITableViewCell {
    
    @IBOutlet weak var profileImageView: ProfileImageView!
    @IBOutlet weak var nameLabel: UsernameLabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var usernameLabel: UsernameLabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var photoImageView: UIImageView!
    
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var likeCountLabel: UILabel!
    @IBOutlet weak var replyButton: UIButton!
    @IBOutlet weak var flagButton: UIButton!
    
    weak var delegate: AlertReplyTableViewCellDelegate?
    
    var alert: PFObject?
    var reply: PFObject?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.profileImageView.layer.cornerRadius = 3
        self.profileImageView.clipsToBounds = true
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setUpCell(reply: PFObject) {
        self.reply = reply
        if let author = reply["author"] as? PFUser {
            self.profileImageView.user = author
            if let profilePhoto = author["photo"] as? PFFile {
                let pfImageView = PFImageView()
                pfImageView.file = profilePhoto
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
            self.usernameLabel.user = author
            self.usernameLabel.text = author.username
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
        
        // Like count.
        if let likeCount = reply["likeCount"] as? Int {
            self.likeCountLabel.text = String(likeCount)
        } else {
            self.likeCountLabel.text = ""
        }
    }
}


// MARK: - Actions

extension AlertReplyTableViewCell {
    @IBAction func onLikeButtonTapped(_ sender: Any) {
//        self.alert?.incrementKey("likeCount")
//        self.alert?.saveInBackground(block: { (completed: Bool, error: Error?) in
//            if error != nil {
//                print(error!.localizedDescription)
//            } else {
//                self.delegate?.alertReplyTableViewCellShouldReload?()
//            }
//        })
    }
    
    @IBAction func onReplyButtonTapped(_ sender: Any) {
        self.delegate?.alertReplyTableViewCellDidTapReply?()
    }
    
    @IBAction func onFlagButtonTapped(_ sender: Any) {
    }
}
