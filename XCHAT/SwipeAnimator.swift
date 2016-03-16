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
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return self.duration
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView()!
        containerView.backgroundColor = UIColor.blackColor()
        
        let coverView = UIView(frame: containerView.frame)
        coverView.backgroundColor = UIColor.blackColor()
        containerView.addSubview(coverView)
        
        let toView = transitionContext.viewForKey(UITransitionContextToViewKey)!
        
        let fromView = transitionContext.viewForKey(UITransitionContextFromViewKey)!
        
        // Add toView to transition container.
        containerView.addSubview(toView)
        containerView.bringSubviewToFront(toView)
        
        // Add black cover view on top to make toView fade-in smoother.
        containerView.bringSubviewToFront(coverView)
        
        UIView.animateWithDuration(self.duration, delay: 0, options: [], animations: { () -> Void in
            fromView.alpha = 0
            coverView.alpha = 0
        }) { _ in
            transitionContext.completeTransition(true)
        }
    }
    
}
