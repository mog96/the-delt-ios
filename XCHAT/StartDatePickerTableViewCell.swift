//
//  StartDatePickerTableViewCell.swift
//  XCHAT
//
//  Created by Mateo Garcia on 1/18/16.
//  Copyright © 2016 Mateo Garcia. All rights reserved.
//

import UIKit

protocol StartDateDelegate {
    func onDateChanged(date: NSDate)
}

class StartDatePickerTableViewCell: UITableViewCell {
    
    @IBOutlet weak var eventDatePicker: UIDatePicker!
    
    var startDateDelegate: StartDateDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.eventDatePicker.addTarget(self, action: "onDateChanged", forControlEvents: UIControlEvents.ValueChanged)
        self.onDateChanged()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func onDateChanged() {
        self.startDateDelegate?.onDateChanged(self.eventDatePicker.date)
    }
}
