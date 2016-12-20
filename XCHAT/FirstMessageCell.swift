//
//  MessageTableViewCell.swift
//  xchat-pat
//
//  Created by Pat Boonyarittipong on 5/13/15.
//  Copyright (c) 2015 patboony. All rights reserved.
//

import UIKit
import Parse
import ParseUI

class FirstMessageCell: UITableViewCell {
    
    @IBOutlet weak var usernameLabel: UsernameLabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var authorProfileImageView: ProfileImageView!
        
    override func awakeFromNib() {
        super.awakeFromNib()
        
        authorProfileImageView.layer.cornerRadius = 2
        authorProfileImageView.clipsToBounds = true
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        self.authorProfileImageView.image = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        messageLabel.preferredMaxLayoutWidth = messageLabel.frame.width
    }
    
    func setUpCellWithPictures(_ message: PFObject, pictures: NSMutableDictionary) {
        let dateFormatter = DateFormatter()
        let calendar = Calendar.current
        let comp = (calendar as NSCalendar).components([.hour, .minute], from: message.createdAt!)
        
        dateFormatter.amSymbol = "a"
        dateFormatter.pmSymbol = "p"
        dateFormatter.dateFormat = "h:mma"
        if comp.minute == 0 {
            dateFormatter.dateFormat = "ha"
        }
        
        let username = message["authorUsername"] as! String
        
        self.usernameLabel.username = username
        self.usernameLabel.text = username
        self.timestampLabel.text = dateFormatter.string(from: message.createdAt!)
        self.messageLabel.text = (message["content"] as! String)

        if let profilePic = pictures[usernameLabel.text!]{
            self.authorProfileImageView.username = username
            self.authorProfileImageView.image = profilePic as? UIImage
        }
        
//        
//        var query = PFUser.query()
//        query?.whereKey("username", equalTo: message.valueForKey("authorUsername") as! String)
//        query?.findObjectsInBackgroundWithBlock({ (users: [AnyObject]?, error: NSError?) -> Void in
//            if let users = users as? [PFObject] {
//                var pfImageView = PFImageView()
//                pfImageView.file = users[0].valueForKey("photo") as? PFFile
//                if let _=pfImageView.file{
//                    pfImageView.loadInBackground { (image: UIImage?, error: NSError?) -> Void in
//                        if error == nil {
//                            
//                            self.authorProfileImageView.image = image
//                        } else {
//                            
//                            // Log details of the failure
//                            println("Error: \(error!) \(error!.userInfo!)")
//                        }
//                    }
//                }
//                
//            }
//        })
    }
    
    func setUpCell(_ message: PFObject) {
        let dateFormatter = DateFormatter()
        let calendar = Calendar.current
        let comp = (calendar as NSCalendar).components([.hour, .minute], from: message.createdAt!)
        
        dateFormatter.amSymbol = "a"
        dateFormatter.pmSymbol = "p"
        dateFormatter.dateFormat = "h:mma"
        if comp.minute == 0 {
            dateFormatter.dateFormat = "ha"
        }
        
        let username = message["authorUsername"] as! String
        self.usernameLabel.username = username
        self.usernameLabel.text = username
        self.timestampLabel.text = dateFormatter.string(from: message.createdAt!)
        self.messageLabel.text = (message["content"] as! String)
        
        let query = PFUser.query()
        query?.whereKey("username", equalTo: message.value(forKey: "authorUsername") as! String)
        query?.findObjectsInBackground(block: { (users: [PFObject]?, error: Error?) -> Void in
            if let users = users {
                let pfImageView = PFImageView()
                let user = users[0]
                self.authorProfileImageView.user = user as? PFUser
                pfImageView.file = user.value(forKey: "photo") as? PFFile
                if let _ = pfImageView.file {
                    pfImageView.load { (image: UIImage?, error: Error?) -> Void in
                        if let error = error {
                        
                            // Log details of the failure
                            print("Error: \(error) \(error.localizedDescription)")
                            
                        } else {
                            self.authorProfileImageView.image = image
                        }
                    }
                }
          
            }
        })
    }
    
}
