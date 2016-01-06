//
//  ProfileCell.swift
//  XCHAT
//
//  Created by Mateo Garcia on 5/27/15.
//  Copyright (c) 2015 Mateo Garcia. All rights reserved.
//

import UIKit

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
        
        print("PREPARING CELL")
        
        self.setUpCell()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // MARK: - Helpers
    
    func setUpCell() {
        if let photo = PFUser.currentUser()?.objectForKey("photo") as? PFFile {
            let pfImageView = PFImageView()
            
            pfImageView.image = UIImage(named: "LOGIN BACKGROUND 1")
            
            print(photo)
            pfImageView.file = photo as PFFile
            pfImageView.loadInBackground { (image: UIImage?, error: NSError?) -> Void in
                if let error = error {
                    // Log details of the failure
                    print("Error: \(error) \(error.userInfo)")
                    
                } else {
                    self.photoImageView.image = image
                }
            }
            
        } else {
            self.photoImageView.image = UIImage(named: "LOGIN BACKGROUND 1")
        }
        
        self.photoImageView.layer.cornerRadius = 3
        self.photoImageView.clipsToBounds = true
        
        if let name = PFUser.currentUser()?.objectForKey("name") as? String {
            self.nameLabel.text = name
            
        } else {
            self.nameLabel.text = "Tap here to setup profile"
        }
        
        if let username = PFUser.currentUser()?.objectForKey("username") as? String {
            self.usernameLabel.text = username
        }
        
        if let numPhotos = PFUser.currentUser()?.objectForKey("numPhotosPosted") as? Int {
            self.numPhotosLabel.text = "\(numPhotos) photos"
        } else {
            self.numPhotosLabel.text = "0 photos"
        }
        
        let query = PFQuery(className: "Photo")
        query.whereKey("username", equalTo: PFUser.currentUser()!.username!)
        query.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, error: NSError?) -> Void in
            if let error = error {
                print(error)
            } else {
                if let objects = objects {
                    var totalFaves = 0
                    for object in objects {
                        totalFaves += object["numFaves"] as! Int
                    }
                    if totalFaves == 1 {
                        self.numFavesLabel.text = "1 fave received"
                    } else {
                        self.numFavesLabel.text = "\(totalFaves) faves received"
                    }
                }
            }
        }
        
        if let numFaves = PFUser.currentUser()?.objectForKey("totalNumFavesReceived") as? Int {
            numFavesLabel.text = "\(numFaves) faves received"
        } else {
            self.numFavesLabel.text = "0 faves received"
        }
    }

}
