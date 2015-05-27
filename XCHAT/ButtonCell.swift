//
//  ButtonCell.swift
//  XCHAT
//
//  Created by Mateo Garcia on 5/21/15.
//  Copyright (c) 2015 Mateo Garcia. All rights reserved.
//

import UIKit

protocol ButtonCellDelegate {
    func addComment(photo: NSMutableDictionary?)
    func updateFaved(photo: NSMutableDictionary?, didUpdateFaved faved: Bool)
}

class ButtonCell: UITableViewCell {
    
    var photo: NSMutableDictionary?
    var delegate: ButtonCellDelegate?
    var faved: Bool!

    @IBOutlet weak var faveButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setUpCell(photo: NSMutableDictionary?) {
        self.photo = photo
        if let faved = photo?.valueForKey("faved") as? Bool {
            self.faved = faved
            if faved {
                faveButton.setImage(UIImage(named: "FAVE_ON"), forState: UIControlState.Normal)
            } else {
                faveButton.setImage(UIImage(named: "FAVE"), forState: UIControlState.Normal)
            }
        }
    }
    
    
    // MARK: Actions

    @IBAction func onFaveButtonTapped(sender: AnyObject) {
        if (!faved) {
            faveButton.setImage(UIImage(named: "FAVE_ON"), forState: UIControlState.Normal)
            delegate?.updateFaved(photo, didUpdateFaved: true)
        } else {
            faveButton.setImage(UIImage(named: "FAVE"), forState: UIControlState.Normal)
            delegate?.updateFaved(photo, didUpdateFaved: false)
        }
        
    }
    
    @IBAction func onCommentButtonTapped(sender: AnyObject) {
        delegate?.addComment(photo)
    }
    
}
