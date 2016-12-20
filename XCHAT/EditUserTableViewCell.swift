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

class EditUserTableViewCell: UITableViewCell {

    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    var infoViewPanGestureOriginalLocation = CGPoint()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.photoImageView.layer.cornerRadius = 2
        self.photoImageView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}


// MARK: - Setup

extension EditUserTableViewCell {
    func setupCell(user: PFUser) {
        if let photo = user.object(forKey: "photo") as? PFFile {
            let pfImageView = PFImageView()
            pfImageView.image = UIImage(named: "LOGIN BACKGROUND 1")
            pfImageView.file = photo as PFFile
            pfImageView.load { (image: UIImage?, error: Error?) -> Void in
                if let error = error {
                    // Log details of the failure
                    print("Error: \(error) \(error.localizedDescription)")
                    
                } else {
                    self.photoImageView.image = image
                }
            }
        }
        self.nameLabel.text = user.username
    }
}
