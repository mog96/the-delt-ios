//
//  MemberCell.swift
//  XCHAT
//
//  Created by Mateo Garcia on 5/27/15.
//  Copyright (c) 2015 Mateo Garcia. All rights reserved.
//

import UIKit
import Parse
import ParseUI

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

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        self.photoImageView.image = nil
    }
    
    // MARK: Setup
    
    func setUpCell(_ user: PFUser, photo: UIImage?) {
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
                nameAndYearString += ", '" + year.substring(from: year.characters.index(year.startIndex, offsetBy: 2))
            } else {
                nameAndYearString = "Class of " + year
            }
        }
        self.nameAndYearLabel.text = nameAndYearString
        
        phoneNumberButton.setTitle(user["phone"] as? String, for: UIControlState())
        emailButton.setTitle(user["email"] as? String, for: UIControlState())
        
        if let photo = user["photo"] as? PFFile {
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
    }
    
    
    // MARK: - Actions
    
    @IBAction func onPhoneNumberTapped(_ sender: AnyObject) {
        /*
        let phoneNumber = self.phoneNumberButton.titleLabel!.text!
        print(phoneNumber)
        
        // TODO: strip number down to numbers.
        UIApplication.sharedApplication().openURL(NSURL(string: "tel://" + phoneNumber)!)
        */
    }
    
    @IBAction func onEmailButtonTapped(_ sender: AnyObject) {
        
        // TODO: Present mail view.
    }
}
