//
//  FeedbackTableViewCell.swift
//  XCHAT
//
//  Created by Mateo Garcia on 1/24/16.
//  Copyright © 2016 Mateo Garcia. All rights reserved.
//

import UIKit

protocol FeedbackDelegate {
    func sendFeedback(type feedbackType: FeedbackType)
}

enum FeedbackType {
    case feedback
    case reportUser
}

class FeedbackTableViewCell: UITableViewCell {
    
    @IBOutlet weak var feedbackButton: UIButton!
    
    var feedbackType: FeedbackType = .feedback
    var delegate: FeedbackDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    @IBAction func onFeedbackButtonTapped(_ sender: AnyObject) {
        self.delegate?.sendFeedback(type: self.feedbackType)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
