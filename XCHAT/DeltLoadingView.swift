//
//  DeltLoadingView.swift
//  XCHAT
//
//  Created by Mateo Garcia on 9/23/16.
//  Copyright © 2016 Mateo Garcia. All rights reserved.
//

import UIKit

class DeltLoadingView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    private var shouldContinue = false
    
    func startAnimating() {
        self.shouldContinue = true
        self.animateDelts()
    }
    
    func stopAnimating() {
        self.shouldContinue = false
    }
    
    private func animateDelts() {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            while self.shouldContinue {
                dispatch_async(dispatch_get_main_queue(), {
                    self.addDeltLabel()
                })
                sleep(1)
            }
        }
    }
    
    private func addDeltLabel() {
        let deltLabel = self.deltLabel()
        self.addSubview(deltLabel)
        deltLabel.hidden = true
        UIView.transitionWithView(deltLabel, duration: 0.5, options: .TransitionCrossDissolve, animations: {
            deltLabel.hidden = false
            }, completion: { _ in
                UIView.transitionWithView(deltLabel, duration: 0.5, options: .TransitionCrossDissolve, animations: {
                    deltLabel.hidden = true
                    }, completion: { _ in
                        deltLabel.removeFromSuperview()
                })
        })
    }
    
    // Returns ∆ label with random origin within this view's bounds.
    private func deltLabel() -> UILabel {
        let deltLabel = UILabel()
        deltLabel.text = "Δ"
        deltLabel.textColor = LayoutUtils.greenColor
        deltLabel.font = UIFont.systemFontOfSize(15)
        deltLabel.sizeToFit()
        deltLabel.frame.origin = self.randomOriginForRect(self.deltLabel().bounds)
        return deltLabel
    }
    
    private func randomOriginForRect(rect: CGRect) -> CGPoint {
        let maxWidth = self.frame.width - rect.width
        let maxHeight = self.frame.height - rect.height
        let randomX = CGFloat(arc4random() / UInt32.max) * maxWidth
        let randomY = CGFloat(arc4random() / UInt32.max) * maxHeight
        return CGPoint(x: randomX, y: randomY)
    }
}
