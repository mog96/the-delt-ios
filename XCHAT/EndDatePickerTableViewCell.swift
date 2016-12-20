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

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func onDateChanged(_ date: Date) {
        let calendar = Calendar.current
        var components = DateComponents()
        components.hour = 1
        
        let endDate = (calendar as NSCalendar).date(byAdding: components, to: date, options: [])
        self.eventDatePicker.setDate(endDate!, animated: true)
    }

}
