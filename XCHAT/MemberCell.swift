//
//  MemberCell.swift
//  XCHAT
//
//  Created by Mateo Garcia on 5/27/15.
//  Copyright (c) 2015 Mateo Garcia. All rights reserved.
//

import UIKit

class MemberCell: UITableViewCell {

    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var nameAndYearLabel: UILabel!
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
    
    override func prepareForReuse() {
        self.photoImageView.image = nil
    }
    
    // MARK: Setup
    
    func setUpCell(user: PFUser, photo: UIImage?) {
        if let username = user["username"] as? String {
            self.usernameLabel.text = "@" + username
        }
        
        var hasName = false
        var nameAndYearString = ""
        if let name = user["name"] as? String {
            nameAndYearString = name
            hasName = true
        }
        if let year = user["class"] as? String {
            if hasName {
                nameAndYearString += ", '" + year.substringFromIndex(year.startIndex.advancedBy(2))
            } else {
                nameAndYearString = "Class of " + year
            }
        } else {
            if !hasName {
                nameAndYearString = "Class of 6969"
            }
        }
        self.nameAndYearLabel.text = nameAndYearString
        
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
        }
    }
    
    
    // MARK: - Actions
    
    @IBAction func onPhoneNumberTapped(sender: AnyObject) {
        /*
        let phoneNumber = self.phoneNumberButton.titleLabel!.text!
        print(phoneNumber)
        
        // TODO: strip number down to numbers.
        UIApplication.sharedApplication().openURL(NSURL(string: "tel://" + phoneNumber)!)
        */
    }
    
    @IBAction func onEmailButtonTapped(sender: AnyObject) {
        
        // TODO: Present mail view.
    }
}
