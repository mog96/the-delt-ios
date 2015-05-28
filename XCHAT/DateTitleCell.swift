//
//  DateTitleCell.swift
//  XCHAT
//
//  Created by Mateo Garcia on 5/25/15.
//  Copyright (c) 2015 Mateo Garcia. All rights reserved.
//

import UIKit

class DateTitleCell: UITableViewCell {
    
    @IBOutlet weak var weekdayLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var artworkImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        artworkImageView.layer.cornerRadius = 2
        artworkImageView.clipsToBounds = true
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setUpCell(event: PFObject) {
        var pfImageView = PFImageView()
        
        // JUST FOR LOLZ
        pfImageView.image = UIImage(named: "ROONEY")
        
        pfImageView.file = event.valueForKey("artwork") as? PFFile
        
        if let _ = pfImageView.file{
            pfImageView.loadInBackground { (artwork: UIImage?, error: NSError?) -> Void in
                if error == nil {
                    self.artworkImageView.image = artwork
                } else {
                    
                    // Log details of the failure
                    println("Error: \(error!) \(error!.userInfo!)")
                }
            }

        }
        
        var dateFormatter = NSDateFormatter()
        let calendar = NSCalendar.currentCalendar()
        
        dateFormatter.AMSymbol = "a"
        dateFormatter.PMSymbol = "p"
        
        var startTime = event["startTime"] as! NSDate
        var comp = calendar.components((.CalendarUnitHour | .CalendarUnitMinute), fromDate: startTime)
        dateFormatter.dateFormat = "h:mma"
        if comp.minute == 0 {
            dateFormatter.dateFormat = "ha"
        }
        var date = dateFormatter.stringFromDate(event["startTime"] as! NSDate) + "-"
        
        var endTime = event["endTime"] as! NSDate
        comp = calendar.components((.CalendarUnitHour | .CalendarUnitMinute), fromDate: endTime)
        dateFormatter.dateFormat = "h:mma"
        if comp.minute == 0 {
            dateFormatter.dateFormat = "ha"
        }
        date += dateFormatter.stringFromDate(event["endTime"] as! NSDate)
        timeLabel.text = date
        
        dateFormatter.dateFormat = "E"
        var weekday = dateFormatter.stringFromDate(startTime)
        var weekdayLetter = weekday[weekday.startIndex]
        weekdayLabel.text = String(weekdayLetter)
        
        dateFormatter.dateFormat = "M/d"
        dateLabel.text = dateFormatter.stringFromDate(startTime)
        
        titleLabel.text = event["name"] as? String
    }
    
}
