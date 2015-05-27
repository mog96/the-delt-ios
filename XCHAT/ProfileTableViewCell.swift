//
//  ProfileTableViewCell.swift
//  XCHAT
//
//  Created by Jim Cai on 5/25/15.
//  Copyright (c) 2015 Mateo Garcia. All rights reserved.
//

import UIKit

class ProfileTableViewCell: UITableViewCell {

    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var realName: UILabel!
    @IBOutlet weak var profilePic: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        if let photo: PFFile=PFUser.currentUser()?.objectForKey("photo") as! PFFile?{
            var pfImageView = PFImageView()
            pfImageView.image = UIImage(named: "profilePic")
            println(photo)
            pfImageView.file = photo as! PFFile
            pfImageView.loadInBackground { (image: UIImage?, error: NSError?) -> Void in
                if error == nil {
                    println("Setting cell photo")
                    self.profilePic.image = image
                } else {
                    // Log details of the failure
                    println("Error: \(error!) \(error!.userInfo!)")
                }
            }

        }
        
        var query = PFQuery(className: "profile")
        query.whereKey("email", equalTo: (PFUser.currentUser()?.username)!)
        query.findObjectsInBackgroundWithBlock { (objects: [AnyObject]?, error: NSError?) -> Void in
            var objs = objects as! [PFObject]
            if objs.count > 0 {
                var profile = objects![0] as! PFObject
                self.userName.text = profile["username"] as? String
                self.realName.text = profile["name"] as? String
            } else {
                self.userName.text = "Please Set Your Name by Tapping"
                self.realName.text = ""
            }            
        }
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
