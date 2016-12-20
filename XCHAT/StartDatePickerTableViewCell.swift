//
//  StartDatePickerTableViewCell.swift
//  XCHAT
//
//  Created by Mateo Garcia on 1/18/16.
//  Copyright © 2016 Mateo Garcia. All rights reserved.
//

import UIKit

protocol StartDateDelegate {
    func onDateChanged(_ date: Date)
}

class StartDatePickerTableViewCell: UITableViewCell {
    
    @IBOutlet weak var eventDatePicker: UIDatePicker!
    
    var startDateDelegate: StartDateDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.eventDatePicker.addTarget(self, action: #selector(StartDatePickerTableViewCell.onDateChanged), for: UIControlEvents.valueChanged)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
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
    
    fileprivate func getNextHourDate() -> Date {
        let calendar = Calendar.current
        var components = (calendar as NSCalendar).components([.era, .year, .month, .day, .hour], from: Date())
        components.hour = components.hour! + 1
        return calendar.date(from: components)!
    }
}
