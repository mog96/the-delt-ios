//
//  NotificationsTableViewCell.swift
//  XCHAT
//
//  Created by Jim Cai on 5/13/15.
//  Copyright (c) 2015 Mateo Garcia. All rights reserved.
//

import UIKit
protocol SwitchDelegate{
    func switchDelegate(_ switchtableViewCell: NotificationTableViewCell, switchValue:Bool)
}

class NotificationTableViewCell: UITableViewCell{

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var onSwitch: UISwitch!
    var delegate: SwitchDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.onSwitch.tintColor = LayoutUtils.blueColor
    }
    
    @IBAction func switchChanged(_ sender: AnyObject) {
        delegate?.switchDelegate(self, switchValue: onSwitch.isOn)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
