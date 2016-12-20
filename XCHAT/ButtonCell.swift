//
//  ButtonCell.swift
//  XCHAT
//
//  Created by Mateo Garcia on 5/21/15.
//  Copyright (c) 2015 Mateo Garcia. All rights reserved.
//

import UIKit
import Parse

protocol ButtonCellDelegate {
    func addComment(_ photo: NSMutableDictionary?)
    func updateFaved(_ photo: NSMutableDictionary?, didUpdateFaved faved: Bool)
    func updateFlagged(_ photo: NSMutableDictionary?, flagged: Bool)
}

class ButtonCell: UITableViewCell {
    
    var photo: NSMutableDictionary?
    var delegate: ButtonCellDelegate?
    var faved = false
    var flagged = false

    @IBOutlet weak var faveButton: UIButton!
    @IBOutlet weak var flagButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        self.faved = false
        self.flagged = false
    }
    
    func setUpCell(_ photo: NSMutableDictionary?) {
        self.photo = photo
        if let favedBy = photo?.value(forKey: "favedBy") as? [String] {
            if let username = PFUser.current()?.username {
                
                print("IS FAVED: \(favedBy.contains(username))")
                
                self.faved = favedBy.contains(username)
                
                print("SETTING FAVED: \(self.faved)")
            }
        }
        
        // TODO: Associate flagged with user.
        if let flagged = photo?["flagged"] as? Bool {
            self.flagged = flagged
        }
        
        print("FAVED: \(self.faved)")
        
        self.faveButton.isSelected = self.faved
        self.flagButton.isSelected = self.flagged
    }
    
    
    // MARK: Actions

    @IBAction func onFaveButtonTapped(_ sender: AnyObject) {
        self.faveButton.isSelected = !self.faved
        delegate?.updateFaved(photo, didUpdateFaved: !self.faved)
    }
    
    @IBAction func onCommentButtonTapped(_ sender: AnyObject) {
        delegate?.addComment(photo)
    }
    
    @IBAction func onFlagButtonTapped(_ sender: AnyObject) {
        
        print("FLAGGED: \(self.flagged)")
        
        self.flagButton.isSelected = !self.flagged
        self.delegate?.updateFlagged(self.photo, flagged: !self.flagged)
    }
    
}
