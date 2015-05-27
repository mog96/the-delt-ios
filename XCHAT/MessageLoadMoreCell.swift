//
//  MessageLoadMoreCell.swift
//  xchat-pat
//
//  Created by Pat Boonyarittipong on 5/25/15.
//  Copyright (c) 2015 patboony. All rights reserved.
//

import UIKit

protocol LoadMoreMessagesDelegate {
    func LoadMoreMessages(MessageLoadMoreCell: MessageLoadMoreCell)
}

class MessageLoadMoreCell: UITableViewCell {
    
    var delegate:LoadMoreMessagesDelegate?
    
    @IBAction func loadMoreMessagesAction(sender: AnyObject) {
        delegate?.LoadMoreMessages(self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
