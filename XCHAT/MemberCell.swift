//
//  MemberCell.swift
//  XCHAT
//
//  Created by Mateo Garcia on 5/27/15.
//  Copyright (c) 2015 Mateo Garcia. All rights reserved.
//

import UIKit

class MemberCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var phoneNumberButton: UIButton!
    @IBOutlet weak var emailButton: UIButton!
    @IBOutlet weak var photoImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.photoImageView.layer.cornerRadius = 2
        self.photoImageView.clipsToBounds = true
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // MARK: Setup
    
    func setUpCell(user: PFUser, photo: UIImage?) {
        nameLabel.text = user["name"] as? String
        
        if let year = user["class"] as? String {
            yearLabel.text = "Class of " + year
        } else {
            yearLabel.text = ""
        }
        
        phoneNumberButton.setTitle(user["phone"] as? String, forState: UIControlState.Normal)
        emailButton.setTitle(user["email"] as? String, forState: UIControlState.Normal)
        
        if let photo = user["photo"] as? PFFile {
            let pfImageView = PFImageView()
            
            pfImageView.file = photo
            pfImageView.loadInBackground { (image: UIImage?, error: NSError?) -> Void in
                if let error = error {
                    // Log details of the failure
                    print("Error: \(error) \(error.userInfo)")
                    
                } else {
                    self.photoImageView.image = image
                }
            }
        }else{
            self.photoImageView.image = UIImage(named: "ROONEY")
        }
    }
}
