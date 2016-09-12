//
//  EditUserTableViewCell.swift
//  XCHAT
//
//  Created by Mateo Garcia on 9/12/16.
//  Copyright © 2016 Mateo Garcia. All rights reserved.
//

import UIKit
import Parse
import ParseUI

protocol EditUserTableViewCellDelegate {
    func deleteUser()
}

class EditUserTableViewCell: UITableViewCell {

    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    var delegate: EditUserTableViewCellDelegate!
    
    var infoViewPanGestureOriginalLocation = CGPoint()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.photoImageView.layer.cornerRadius = 2
        self.photoImageView.clipsToBounds = true
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}


// MARK: - Setup

extension EditUserTableViewCell {
    func setupCell(user user: PFUser) {
        if let photo = user.objectForKey("photo") as? PFFile {
            let pfImageView = PFImageView()
            pfImageView.image = UIImage(named: "LOGIN BACKGROUND 1")
            pfImageView.file = photo as PFFile
            pfImageView.loadInBackground { (image: UIImage?, error: NSError?) -> Void in
                if let error = error {
                    // Log details of the failure
                    print("Error: \(error) \(error.userInfo)")
                    
                } else {
                    self.photoImageView.image = image
                }
            }
        }
        self.nameLabel.text = user.username
    }
}


// MARK: - Actions

extension EditUserTableViewCell {
    @IBAction func onDeleteButtonTapped(sender: AnyObject) {
        self.delegate.deleteUser()
    }
    
    func showDeleteButton() {
        UIView.animateWithDuration(0.2, delay: 0, options: .CurveEaseOut, animations: {
            let newOrigin = CGPoint(x: -(self.contentView.frame.width - self.deleteButton.frame.origin.x), y: 0)
            self.infoView.frame.origin = newOrigin
        }, completion: nil)
    }
    
    func hideDeleteButton() {
        UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseOut, animations: {
            self.infoView.frame.origin = CGPointZero
        }, completion: nil)
    }
}