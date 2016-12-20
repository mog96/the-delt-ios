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
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setUpCell(_ event: PFObject) {
        self.artworkImageView.image = nil
        let pfImageView = PFImageView()
        pfImageView.file = event.value(forKey: "artwork") as? PFFile
        if let _ = pfImageView.file {
            pfImageView.load { (artwork: UIImage?, error: Error?) -> Void in
                if let error = error {
                    // Log details of the failure
                    print("Error: \(error) \(error._userInfo)")
                } else {
                    self.artworkImageView.image = artwork
                }
            }
        } else {
            self.artworkImageView.image = UIImage(named: "LEOPARD PRINT")
        }
        
        let dateFormatter = DateFormatter()
        let calendar = Calendar.current
        
        dateFormatter.amSymbol = "a"
        dateFormatter.pmSymbol = "p"
        
        let startTime = event["startTime"] as! Date
        var comp = (calendar as NSCalendar).components([.hour, .minute], from: startTime)
        dateFormatter.dateFormat = "h:mma"
        if comp.minute == 0 {
            dateFormatter.dateFormat = "ha"
        }
        var date = dateFormatter.string(from: event["startTime"] as! Date) + "-"
        
        let endTime = event["endTime"] as! Date
        comp = (calendar as NSCalendar).components([.hour, .minute], from: endTime)
        dateFormatter.dateFormat = "h:mma"
        if comp.minute == 0 {
            dateFormatter.dateFormat = "ha"
        }
        date += dateFormatter.string(from: event["endTime"] as! Date)
        timeLabel.text = date
        
        dateFormatter.dateFormat = "E"
        let weekday = dateFormatter.string(from: startTime)
        let prefix = weekday.substring(to: weekday.characters.index(weekday.startIndex, offsetBy: 2))
        switch prefix {
        case "Th":
            fallthrough
        case "Sa":
            fallthrough
        case "Su":
            self.weekdayLabel.text = prefix
        default:
            self.weekdayLabel.text = String(weekday[weekday.startIndex])
        }
        
        dateFormatter.dateFormat = "M/d"
        dateLabel.text = dateFormatter.string(from: startTime)
        
        titleLabel.text = event["name"] as? String
    }
    
}
