//
//  DeltLoadingView.swift
//  XCHAT
//
//  Created by Mateo Garcia on 9/23/16.
//  Copyright © 2016 Mateo Garcia. All rights reserved.
//

import UIKit

class DeltLoadingView: UIView {
    
    fileprivate var shouldContinue = false
    fileprivate var exemptFrames: [CGRect]?
    var deltColor: UIColor! {
        didSet {
            self.deltColorSet = [self.deltColor]
        }
    }
    var deltColorSet: [UIColor]!
    
    var deltRepeatInterval: TimeInterval = 0.3
    var deltFadeDuration: TimeInterval = 0.5
    
    init(frame: CGRect, exemptFrames: CGRect...) {
        super.init(frame: frame)
        self.exemptFrames = exemptFrames
        self.commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    func commonInit() {
        self.deltColor = LayoutUtils.greenColor
    }
    
    func addExemptFrames(_ exemptFrames: CGRect...) {
        if self.exemptFrames != nil {
            self.exemptFrames!.append(contentsOf: exemptFrames)
        } else {
            self.exemptFrames = exemptFrames
        }
        
        print("EXEMPT FRAMES:", self.exemptFrames)
    }
    
    func startAnimating() {
        self.isHidden = false
        self.shouldContinue = true
        self.animateDelts()
    }
    
    func stopAnimating() {
        self.shouldContinue = false
    }
}


// MARK: - Helpers

extension DeltLoadingView {
    fileprivate func animateDelts() {
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async {
            var colorIndex = 0
            while self.shouldContinue {
                DispatchQueue.main.async(execute: {
                    self.addDeltLabel(color: self.deltColorSet[colorIndex])
                })
                // let interval = 0.4 + Double(arc4random()) / Double(UInt32.max) * 0.1
                Thread.sleep(forTimeInterval: self.deltRepeatInterval)
                colorIndex = colorIndex % self.deltColorSet.count
            }
        }
    }
    
    fileprivate func addDeltLabel(color: UIColor) {
        
        print("ADD DELT LABEL")
        
        let delt = self.deltLabel(color: color)
        delt.alpha = 0
        self.addSubview(delt)
        let fadeDuration: TimeInterval = self.deltFadeDuration
        UIView.animate(withDuration: fadeDuration, animations: { 
            delt.alpha = 1
            }, completion: { _ in
                UIView.animate(withDuration: fadeDuration, animations: { 
                    delt.alpha = 0
                }, completion: { _ in
                    delt.removeFromSuperview()
                }) 
        })
    }
    
    // Returns ∆ label with random origin within this view's bounds.
    fileprivate func deltLabel(color: UIColor) -> UILabel {
        let deltLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        deltLabel.text = "Δ"
        deltLabel.textColor = color
        deltLabel.font = UIFont.systemFont(ofSize: 15)
        deltLabel.sizeToFit()
        deltLabel.frame = self.randomFrameWithSize(deltLabel.bounds.size)
        return deltLabel
    }
    
    fileprivate func randomFrameWithSize(_ size: CGSize) -> CGRect {
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
    
    fileprivate func generateRandomFrameWithSize(_ size: CGSize) -> CGRect {
        let maxWidth = self.frame.width - size.width
        let maxHeight = self.frame.height - size.height
        let randomX = CGFloat(arc4random()) / CGFloat(UInt32.max) * maxWidth
        let randomY = CGFloat(arc4random()) / CGFloat(UInt32.max) * maxHeight
        return CGRect(x: randomX, y: randomY, width: size.width, height: size.height)
    }
}
