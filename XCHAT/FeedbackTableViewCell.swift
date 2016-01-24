//
//  FeedbackTableViewCell.swift
//  XCHAT
//
//  Created by Mateo Garcia on 1/24/16.
//  Copyright © 2016 Mateo Garcia. All rights reserved.
//

protocol FeedbackDelegate {
    func presentReportUserMailCompose()
}

class FeedbackTableViewCell: UITableViewCell {
    
    @IBOutlet weak var feedbackButton: UIButton!
    
    var delegate: FeedbackDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    @IBAction func onFeedbackButtonTapped(sender: AnyObject) {
        delegate?.presentReportUserMailCompose()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
