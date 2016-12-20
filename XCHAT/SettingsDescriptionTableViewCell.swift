//
//  NotificationsDescriptionTableViewCell.swift
//  XCHAT
//
//  Created by Mateo Garcia on 1/17/16.
//  Copyright © 2016 Mateo Garcia. All rights reserved.
//

import UIKit

class SettingsDescriptionTableViewCell: UITableViewCell {
    
    @IBOutlet weak var descriptionLabel: UILabel!
        
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func setDescription(_ description: String) {
        let text = NSMutableAttributedString(string: description)
        let labelStyle = NSMutableParagraphStyle()
        labelStyle.lineSpacing = 3
        labelStyle.alignment = NSTextAlignment.left
        text.addAttribute(NSParagraphStyleAttributeName, value: labelStyle, range: NSMakeRange(0, text.length))
        self.descriptionLabel.attributedText = text
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
