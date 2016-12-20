//
//  MessageLoadMoreCell.swift
//  xchat-pat
//
//  Created by Pat Boonyarittipong on 5/25/15.
//  Copyright (c) 2015 patboony. All rights reserved.
//

import UIKit

protocol LoadMoreMessagesDelegate {
    func LoadMoreMessages(_ MessageLoadMoreCell: MessageLoadMoreCell)
}

class MessageLoadMoreCell: UITableViewCell {
    
    var delegate:LoadMoreMessagesDelegate?
    
    @IBAction func loadMoreMessagesAction(_ sender: AnyObject) {
        delegate?.LoadMoreMessages(self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
