//
//  DateTitleCell.swift
//  XCHAT
//
//  Created by Mateo Garcia on 5/25/15.
//  Copyright (c) 2015 Mateo Garcia. All rights reserved.
//

import UIKit
import Parse
import ParseUI

class DateTitleCell: UITableViewCell {
    
    @IBOutlet weak var weekdayLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var artworkImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.artworkImageView.layer.cornerRadius = 2
        self.artworkImageView.clipsToBounds = true
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setUpCell(event: PFObject) {
        self.artworkImageView.image = nil
        let pfImageView = PFImageView()
        pfImageView.file = event.valueForKey("artwork") as? PFFile
        if let _ = pfImageView.file {
            pfImageView.loadInBackground { (artwork: UIImage?, error: NSError?) -> Void in
                if let error = error {
                    // Log details of the failure
                    print("Error: \(error) \(error.userInfo)")
                } else {
                    self.artworkImageView.image = artwork
                }
            }
        } else {
            self.artworkImageView.image = UIImage(named: "LEOPARD PRINT")
        }
        
        let dateFormatter = NSDateFormatter()
        let calendar = NSCalendar.currentCalendar()
        
        dateFormatter.AMSymbol = "a"
        dateFormatter.PMSymbol = "p"
        
        let startTime = event["startTime"] as! NSDate
        var comp = calendar.components([.Hour, .Minute], fromDate: startTime)
        dateFormatter.dateFormat = "h:mma"
        if comp.minute == 0 {
            dateFormatter.dateFormat = "ha"
        }
        var date = dateFormatter.stringFromDate(event["startTime"] as! NSDate) + "-"
        
        let endTime = event["endTime"] as! NSDate
        comp = calendar.components([.Hour, .Minute], fromDate: endTime)
        dateFormatter.dateFormat = "h:mma"
        if comp.minute == 0 {
            dateFormatter.dateFormat = "ha"
        }
        date += dateFormatter.stringFromDate(event["endTime"] as! NSDate)
        timeLabel.text = date
        
        dateFormatter.dateFormat = "E"
        let weekday = dateFormatter.stringFromDate(startTime)
        if weekday.hasPrefix("Th") {
            self.weekdayLabel.text = "Th"
        } else {
            self.weekdayLabel.text = String(weekday[weekday.startIndex])
        }
        
        dateFormatter.dateFormat = "M/d"
        dateLabel.text = dateFormatter.stringFromDate(startTime)
        
        titleLabel.text = event["name"] as? String
    }
    
}
