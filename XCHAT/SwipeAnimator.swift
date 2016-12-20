//
//  FadeAnimator.swift
//  XCHAT
//
//  Created by Mateo Garcia on 03/16/16.
//  Copyright © 2015 com.thedelt. All rights reserved.
//

import UIKit

class SwipeAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    let duration = 0.25
    var presenting = true
    var originFrame = CGRect.zero
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return self.duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        containerView.backgroundColor = UIColor.black
        
        let coverView = UIView(frame: containerView.frame)
        coverView.backgroundColor = UIColor.black
        containerView.addSubview(coverView)
        
        let toView = transitionContext.view(forKey: UITransitionContextViewKey.to)!
        
        let fromView = transitionContext.view(forKey: UITransitionContextViewKey.from)!
        
        // Add toView to transition container.
        containerView.addSubview(toView)
        containerView.bringSubview(toFront: toView)
        
        // Add black cover view on top to make toView fade-in smoother.
        containerView.bringSubview(toFront: coverView)
        
        UIView.animate(withDuration: self.duration, delay: 0, options: [], animations: { () -> Void in
            fromView.alpha = 0
            coverView.alpha = 0
        }) { _ in
            transitionContext.completeTransition(true)
        }
    }
    
}
