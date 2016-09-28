//
//  CommentCell.swift
//  XCHAT
//
//  Created by Mateo Garcia on 5/21/15.
//  Copyright (c) 2015 Mateo Garcia. All rights reserved.
//

import UIKit

class CommentCell: UITableViewCell {
    
    var commentIndex: Int!
    
    @IBOutlet weak var usernameLabel: UsernameLabel!
    @IBOutlet weak var commentLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setUpCell(photo: NSMutableDictionary?) {
        
        if let comments = photo?.valueForKey("comments") as? [[String]] {
            let username = comments[commentIndex][0]
            self.usernameLabel.username = username
            self.usernameLabel.text = username
            self.commentLabel.text = comments[commentIndex][1] // Comment.
        }
    }

}
