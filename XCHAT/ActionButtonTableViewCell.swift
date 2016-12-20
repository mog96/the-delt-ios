//
//  LogOutTableViewCell.swift
//  XCHAT
//
//  Created by Jim Cai on 5/20/15.
//  Copyright (c) 2015 Mateo Garcia. All rights reserved.
//

import UIKit

protocol ActionButtonCellDelegate {
    func actionButtonCell(tappedBySender sender: AnyObject)
}

class ActionButtonTableViewCell: UITableViewCell {
    
    @IBOutlet weak var actionButton: UIButton!
    
    var delegate: ActionButtonCellDelegate?
    var identifier = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    @IBAction func onActionButtonTapped(_ sender: AnyObject) {
        self.delegate?.actionButtonCell(tappedBySender: sender)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
