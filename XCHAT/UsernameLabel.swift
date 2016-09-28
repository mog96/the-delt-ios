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
    
    var user: PFUser?
    var username: String?
    
    var tapGestureRecognizer: UITapGestureRecognizer!
    
    init(user aUser: PFUser, frame: CGRect) {
        super.init(frame: frame)
        self.user = aUser
        self.username = aUser.username
        self.commonInit()
    }
    
    init(username aUsername: String, frame: CGRect) {
        super.init(frame: frame)
        self.username = aUsername
        self.commonInit()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    private func commonInit() {
        self.userInteractionEnabled = true
        self.tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.onTap))
        self.addGestureRecognizer(self.tapGestureRecognizer)
    }
}


// MARK: - Actions

extension UsernameLabel {
    func onTap() {
        print("USER:", self.user?.username)
        print("USERNAME:", self.username)
    }
}
