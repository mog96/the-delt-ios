//
//  PhotoCell.swift
//  XCHAT
//
//  Created by Mateo Garcia on 5/19/15.
//  Copyright (c) 2015 Mateo Garcia. All rights reserved.
//

import UIKit

class PhotoCell: UITableViewCell {
    
    @IBOutlet weak var photoImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setUpCell(photo: NSMutableDictionary?) {
        var pfImageView = PFImageView()
        
        // JUST FOR LOLZ
        pfImageView.image = UIImage(named: "ROONEY")
        
        pfImageView.file = photo?.valueForKey("imageFile") as? PFFile
        pfImageView.loadInBackground { (image: UIImage?, error: NSError?) -> Void in
            if error == nil {
                self.photoImageView.image = image
            } else {
                
                // Log details of the failure
                println("Error: \(error!) \(error!.userInfo!)")
            }
        }
    }
    
}
