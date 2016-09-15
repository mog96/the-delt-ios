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
        
        self.eventDatePicker.addTarget(self, action: #selector(StartDatePickerTableViewCell.onDateChanged), forControlEvents: UIControlEvents.ValueChanged)
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func onDateChanged() {
        self.startDateDelegate?.onDateChanged(self.eventDatePicker.date)
        print("DATE:", self.eventDatePicker.date)
    }
}


// MARK: - Helpers

extension StartDatePickerTableViewCell {
    func setDateToNextHour() {
        self.eventDatePicker.setDate(self.getNextHourDate(), animated: true)
        self.onDateChanged()
        print("DATE:", self.eventDatePicker.date)
    }
    
    private func getNextHourDate() -> NSDate {
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Era, .Year, .Month, .Day, .Hour], fromDate: NSDate())
        components.hour = components.hour + 1
        return calendar.dateFromComponents(components)!
    }
}
