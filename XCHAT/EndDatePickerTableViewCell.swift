//
//  EndDatePickerTableViewCell.swift
//  XCHAT
//
//  Created by Mateo Garcia on 1/18/16.
//  Copyright © 2016 Mateo Garcia. All rights reserved.
//

import UIKit

class EndDatePickerTableViewCell: UITableViewCell, StartDateDelegate {
    
    @IBOutlet weak var eventDatePicker: UIDatePicker!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func onDateChanged(date: NSDate) {
        let calendar = NSCalendar.currentCalendar()
        let components = NSDateComponents()
        components.hour = 1
        
        let endDate = calendar.dateByAddingComponents(components, toDate: date, options: [])
        self.eventDatePicker.setDate(endDate!, animated: true)
    }

}
