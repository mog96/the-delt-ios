//
//  DeltLoadingView.swift
//  XCHAT
//
//  Created by Mateo Garcia on 9/23/16.
//  Copyright © 2016 Mateo Garcia. All rights reserved.
//

import UIKit

class DeltLoadingView: UIView {
    
    private var shouldContinue = false
    private var exemptFrames: [CGRect]?
    
    init(frame: CGRect, exemptFrames: CGRect...) {
        super.init(frame: frame)
        self.exemptFrames = exemptFrames
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func addExemptFrames(exemptFrames: CGRect...) {
        if self.exemptFrames != nil {
            self.exemptFrames!.appendContentsOf(exemptFrames)
        } else {
            self.exemptFrames = exemptFrames
        }
        
        print("EXEMPT FRAMES:", self.exemptFrames)
    }
    
    func startAnimating() {
        self.shouldContinue = true
        self.animateDelts()
    }
    
    func stopAnimating() {
        self.shouldContinue = false
    }
}


// MARK: - Helpers

extension DeltLoadingView {
    private func animateDelts() {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            while self.shouldContinue {
                dispatch_async(dispatch_get_main_queue(), {
                    self.addDeltLabel()
                })
                // let interval = 0.4 + Double(arc4random()) / Double(UInt32.max) * 0.1
                NSThread.sleepForTimeInterval(0.3)
            }
        }
    }
    
    private func addDeltLabel() {
        let delt = self.deltLabel()
        delt.hidden = true
        self.addSubview(delt)
        UIView.transitionWithView(delt, duration: 0.5, options: .TransitionCrossDissolve, animations: {
            delt.hidden = false
            }, completion: { _ in
                UIView.transitionWithView(delt, duration: 0.5, options: .TransitionCrossDissolve, animations: {
                    delt.hidden = true
                    }, completion: { _ in
                        delt.removeFromSuperview()
                })
        })
    }
    
    // Returns ∆ label with random origin within this view's bounds.
    private func deltLabel() -> UILabel {
        let deltLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        deltLabel.text = "Δ"
        deltLabel.textColor = LayoutUtils.greenColor
        deltLabel.font = UIFont.systemFontOfSize(15)
        deltLabel.sizeToFit()
        deltLabel.frame = self.randomFrameWithSize(deltLabel.bounds.size)
        return deltLabel
    }
    
    private func randomFrameWithSize(size: CGSize) -> CGRect {
        var randomFrame: CGRect!
        if let exemptFrames = self.exemptFrames {
            var intersectsExemptFrame = false
            repeat {
                randomFrame = self.generateRandomFrameWithSize(size)
                exemptFrames.forEach({ intersectsExemptFrame = $0.intersects(randomFrame) })
            } while intersectsExemptFrame
        } else {
            randomFrame = self.generateRandomFrameWithSize(size)
        }
        return randomFrame
    }
    
    private func generateRandomFrameWithSize(size: CGSize) -> CGRect {
        let maxWidth = self.frame.width - size.width
        let maxHeight = self.frame.height - size.height
        let randomX = CGFloat(arc4random()) / CGFloat(UInt32.max) * maxWidth
        let randomY = CGFloat(arc4random()) / CGFloat(UInt32.max) * maxHeight
        return CGRect(x: randomX, y: randomY, width: size.width, height: size.height)
    }
}
