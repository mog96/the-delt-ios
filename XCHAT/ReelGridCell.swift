//
//  ReelCell.swift
//  XCHAT
//
//  Created by Mateo Garcia on 5/18/15.
//  Copyright (c) 2015 Mateo Garcia. All rights reserved.
//

import UIKit
import Parse
import ParseUI

class ReelGridCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    func setUpCell(_ photo: NSMutableDictionary?) {
        let pfImageView = PFImageView()
        pfImageView.image = UIImage(named: "ROONEY")
        pfImageView.file = photo?.value(forKey: "imageFile") as? PFFile
        pfImageView.load { (image: UIImage?, error: Error?) -> Void in
            if let error = error {
                // Log details of the failure
                print("Error: \(error) \(error.localizedDescription)")
                
            } else {
                
                print("Setting cell photo")
                
                self.imageView.image = image
            }
        }
    }
}
