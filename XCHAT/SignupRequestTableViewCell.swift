//
//  SignupRequestTableViewCell.swift
//  XCHAT
//
//  Created by Mateo Garcia on 9/28/16.
//  Copyright © 2016 Mateo Garcia. All rights reserved.
//

import UIKit
import Parse

protocol SignupRequestTableViewCellDelegate {
    func signupRequestTableViewCell(didApproveUser user: PFObject)
}

class SignupRequestTableViewCell: UITableViewCell {
    
    @IBOutlet weak var approveButton: UIButton!
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    var delegate: SignupRequestTableViewCellDelegate?
    
    var infoViewPanGestureOriginalLocation = CGPoint()
    
    var signupRequest: PFObject?
    
    var nameLabelColor: UIColor!
    var usernameLabelColor: UIColor!
    var emailLabelColor: UIColor!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.nameLabelColor = self.nameLabel.textColor
        self.usernameLabelColor = self.usernameLabel.textColor
        self.emailLabelColor = self.emailLabel.textColor
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        self.nameLabel.textColor = self.nameLabelColor
        self.usernameLabel.textColor = self.usernameLabelColor
        self.emailLabel.textColor = self.emailLabelColor
    }
}


// MARK: - Setup

extension SignupRequestTableViewCell {
    func setupCell(signupRequest object: PFObject?) {
        self.signupRequest = object
        
        if let name = self.signupRequest?.objectForKey("name") as? String {
            self.nameLabel.text = name
        } else {
            self.nameLabel.text = "[No name]"
            self.nameLabel.textColor = UIColor.darkGrayColor()
        }
        
        if let email = self.signupRequest?.objectForKey("email") as? String {
            self.emailLabel.text = email
        } else {
            self.nameLabel.text = "[No email]"
            self.nameLabel.textColor = UIColor.darkGrayColor()
        }
        
        if let username = self.signupRequest?.objectForKey("username") as? String {
            self.usernameLabel.text = "@" + username
        } else {
            self.nameLabel.text = "[No username]"
            self.nameLabel.textColor = UIColor.darkGrayColor()
        }
    }
}


// MARK: - Actions

extension SignupRequestTableViewCell {
    @IBAction func onApproveButtonTapped(sender: AnyObject) {
        if let object = self.signupRequest {
            self.delegate?.signupRequestTableViewCell(didApproveUser: object)
        }
    }
    
    func showApproveButton() {
        UIView.animateWithDuration(0.2, delay: 0, options: .CurveEaseOut, animations: {
            let newOrigin = CGPoint(x: -(self.contentView.frame.width - self.approveButton.frame.origin.x), y: 0)
            self.infoView.frame.origin = newOrigin
            }, completion: nil)
    }
    
    func hideApproveButton() {
        UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseOut, animations: {
            self.infoView.frame.origin = CGPointZero
            }, completion: nil)
    }
}
