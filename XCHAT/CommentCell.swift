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

    @IBOutlet weak var usernameLabel: UILabel!
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
        
        // screennameLabel.text = photo?["screenname"] as? String
        
        if let comments = photo?.valueForKey("comments") as? [[String]] {
            usernameLabel.text = comments[commentIndex][0]
            commentLabel.text = comments[commentIndex][1]
        }
    }

}
