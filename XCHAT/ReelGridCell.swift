//
//  ReelCell.swift
//  XCHAT
//
//  Created by Mateo Garcia on 5/18/15.
//  Copyright (c) 2015 Mateo Garcia. All rights reserved.
//

import UIKit

class ReelGridCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    func setUpCell(photo: NSMutableDictionary?) {
        var pfImageView = PFImageView()
        pfImageView.image = UIImage(named: "ROONEY")
        pfImageView.file = photo?.valueForKey("imageFile") as? PFFile
        pfImageView.loadInBackground { (image: UIImage?, error: NSError?) -> Void in
            if error == nil {
                println("Setting cell photo")
                self.imageView.image = image
            } else {
                // Log details of the failure
                println("Error: \(error!) \(error!.userInfo!)")
            }
        }
    }
}
