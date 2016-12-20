//
//  PhotoCell.swift
//  XCHAT
//
//  Created by Mateo Garcia on 5/19/15.
//  Copyright (c) 2015 Mateo Garcia. All rights reserved.
//

import UIKit
import Parse
import ParseUI

class PhotoCell: UITableViewCell {
    
    @IBOutlet weak var photoImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        self.photoImageView.image = nil
    }
    
    func setUpCell(_ photo: NSMutableDictionary?) {
        let pfImageView = PFImageView()
        
        // JUST FOR LOLZ
        pfImageView.image = UIImage(named: "ROONEY")
        
        pfImageView.file = photo?.value(forKey: "imageFile") as? PFFile
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
