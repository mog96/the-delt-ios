//
//  UsernameLabel.swift
//  XCHAT
//
//  Created by Mateo Garcia on 9/27/16.
//  Copyright © 2016 Mateo Garcia. All rights reserved.
//

import UIKit
import Parse

class UsernameLabel: UILabel {
    
    var user: PFUser!
    
    var tapGestureRecognizer: UITapGestureRecognizer!

    override func awakeFromNib() {
        self.tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.onTap))
        self.addGestureRecognizer(self.tapGestureRecognizer)
    }
}


// MARK: - Actions

extension UsernameLabel {
    func onTap() {
        print("USERNAME LABEL TAPPED")
    }
}
