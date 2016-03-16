//
//  PhotoVideoCell.swift
//  XCHAT
//
//  Created by Mateo Garcia on 3/15/16.
//  Copyright (c) 2015 Mateo Garcia. All rights reserved.
//

import UIKit

@objc protocol PhotoVideoCellDelegate {
    func presentVideoDetailViewController(videoFile file: PFFile)
}

class PhotoVideoCell: UITableViewCell {
    
    @IBOutlet weak var controlsView: UIView!
    @IBOutlet weak var photoImageView: UIImageView!
    
    var videoFile: PFFile?
    
    weak var delegate: PhotoVideoCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        self.photoImageView.image = nil
    }
    
    func setUpCell(photo: NSMutableDictionary?) {
        if let photo = photo {
            
            // Video.
            if let file = photo.valueForKey("videoFile") as? PFFile {
                
                // print("file", file)
                
                print("VIDEO!")
                
                let pfImageView = PFImageView()
                
                // JUST FOR LOLZ
                pfImageView.image = UIImage(named: "ROONEY")
                
                // Load thumbnail image.
                pfImageView.file = photo.valueForKey("imageFile") as? PFFile
                pfImageView.loadInBackground { (image: UIImage?, error: NSError?) -> Void in
                    if let error = error {
                        // Log details of the failure
                        print("Error: \(error) \(error.userInfo)")
                        
                    } else {
                        self.photoImageView.image = image
                    }
                }
                self.videoFile = file
                
            // Photo.
            } else {
                let file = photo.valueForKey("imageFile") as! PFFile
                let pfImageView = PFImageView()
                
                // JUST FOR LOLZ
                pfImageView.image = UIImage(named: "ROONEY")
                
                pfImageView.file = file
                pfImageView.loadInBackground { (image: UIImage?, error: NSError?) -> Void in
                    if let error = error {
                        // Log details of the failure
                        print("Error: \(error) \(error.userInfo)")
                        
                    } else {
                        self.photoImageView.image = image
                    }
                }
            }
            
        } else {
            
            // Error.
            self.photoImageView.backgroundColor = UIColor.redColor()
        }
    }
    
}
