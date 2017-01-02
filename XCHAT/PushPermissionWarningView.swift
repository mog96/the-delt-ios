//
//  PushPermissionWarningView.swift
//  XCHAT
//
//  Created by Mateo Garcia on 1/2/17.
//  Copyright © 2017 Mateo Garcia. All rights reserved.
//

import UIKit

class PushPermissionWarningView: UIView {

    @IBOutlet weak var okButton: UIButton!
    init(frame: CGRect, exemptFrames: CGRect...) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    func commonInit() {
        return
    }
    
    override func awakeFromNib() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.onPermissionRequestDismissed), name: Notification.Name("PushNotificationPermissionRequestDismissed"), object: nil)
    }
}


// MARK: - Helpers

extension PushPermissionWarningView {
    func onPermissionRequestDismissed() {
        UIView.transition(with: self, duration: 1, options: .transitionCrossDissolve, animations: {
            self.isHidden = true
        }, completion: nil)
    }
}


// MARK: - Actions

extension PushPermissionWarningView {
    @IBAction func okButtonTapped(_ sender: Any) {
        AppDelegate.registerForPushNotifications(UIApplication.shared)
        
        self.isHidden = true
    }
}
