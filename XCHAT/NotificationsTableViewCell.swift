//
//  NotificationsTableViewCell.swift
//  XCHAT
//
//  Created by Jim Cai on 5/13/15.
//  Copyright (c) 2015 Mateo Garcia. All rights reserved.
//

import UIKit
protocol SwitchDelegate{
    func switchDelegate(switchtableViewCell: NotificationsTableViewCell, switchValue:Bool)
}

class NotificationsTableViewCell: UITableViewCell{

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var onSwitch: UISwitch!
    var delegate: SwitchDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    @IBAction func switchChanged(sender: AnyObject) {
        delegate?.switchDelegate(self, switchValue: onSwitch.on)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
