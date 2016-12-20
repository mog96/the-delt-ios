//
//  ProfileCell.swift
//  XCHAT
//
//  Created by Mateo Garcia on 5/27/15.
//  Copyright (c) 2015 Mateo Garcia. All rights reserved.
//

import UIKit
import Parse
import ParseUI

class ProfileCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var numPhotosLabel: UILabel!
    @IBOutlet weak var numFavesLabel: UILabel!
    @IBOutlet weak var photoImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setUpCell()
    }
    
    override func prepareForReuse() {
        self.setUpCell()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    // MARK: - Helpers
    
    func setUpCell() {
        if let photo = PFUser.current()?.object(forKey: "photo") as? PFFile {
            let pfImageView = PFImageView()
            pfImageView.image = UIImage(named: "LOGIN BACKGROUND 1")
            
            print(photo)
            
            pfImageView.file = photo as PFFile
            pfImageView.load { (image: UIImage?, error: Error?) -> Void in
                if let error = error {
                    // Log details of the failure
                    print("Error: \(error) \(error._userInfo)")
                    
                } else {
                    self.photoImageView.image = image
                }
            }
        } else {
            self.photoImageView.image = UIImage(named: "LOGIN BACKGROUND 1")
        }
        self.photoImageView.layer.cornerRadius = 3
        self.photoImageView.clipsToBounds = true
        
        // Set name/prompt to set up profile.
        if let name = PFUser.current()?.object(forKey: "name") as? String {
            self.nameLabel.text = name
            self.nameLabel.textColor = LayoutUtils.blueColor
        } else {
            self.nameLabel.text = "Tap here to setup profile"
            self.nameLabel.textColor = UIColor.red
        }
        
        if let username = PFUser.current()?.object(forKey: "username") as? String {
            self.usernameLabel.text = username
        }
        
        if let numPhotos = PFUser.current()?.object(forKey: "numPhotosPosted") as? Int {
            self.numPhotosLabel.text = "\(numPhotos) photos"
        } else {
            self.numPhotosLabel.text = "0 photos"
        }
        
        // Update user's total num faves by fetching from server, summing, and saving to user's table entry.
        let query = PFQuery(className: "Photo")
        if let username = PFUser.current()?.username {
            query.whereKey("username", equalTo: username)
            query.findObjectsInBackground { (objects: [PFObject]?, error: Error?) -> Void in
                if let error = error {
                    print(error)
                } else {
                    if let objects = objects {
                        var totalFaves = 0
                        for object in objects {
                            totalFaves += object["numFaves"] as! Int
                        }
                        
                        // Save current user's total num faves.
                        PFUser.current()?.setObject(totalFaves, forKey: "totalNumFavesReceived")
                        PFUser.current()?.saveInBackground(block: { (success: Bool, error: Error?) -> Void in
                            if error == nil {
                                if let numFaves = PFUser.current()?.object(forKey: "totalNumFavesReceived") as? Int {
                                    if numFaves == 1 {
                                        self.numFavesLabel.text = "1 fave received"
                                    } else {
                                        self.numFavesLabel.text = "\(numFaves) faves received"
                                    }
                                } else {
                                    self.numFavesLabel.text = "0 faves received"
                                }
                            } else {
                                print(error)
                            }
                        })
                    }
                }
            }
        }
    }

}
