//
//  LogOutTableViewCell.swift
//  XCHAT
//
//  Created by Jim Cai on 5/20/15.
//  Copyright (c) 2015 Mateo Garcia. All rights reserved.
//

import UIKit

protocol LoggedOutDelegate{
    func loggedOutDelegate(logoutTableViewCell : LogOutTableViewCell)
}
class LogOutTableViewCell: UITableViewCell {
    var delegate: LoggedOutDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func logoutPressed(sender: AnyObject){
        delegate?.loggedOutDelegate(self)
    }
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
