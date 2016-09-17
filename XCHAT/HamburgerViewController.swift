//
//  HamburgerViewController.swift
//  chirpin
//
//  Created by Mateo Garcia on 5/6/15.
//  Copyright (c) 2015 Mateo Garcia. All rights reserved.
//

import UIKit

class HamburgerViewController: UIViewController {
    
    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet var panGestureRecognizer: UIPanGestureRecognizer!
    @IBOutlet var tapGestureRecognizer: UITapGestureRecognizer!
    
    let xThreshold = 100
    var contentViewOriginalOrigin: CGPoint!
    var screenSize: CGRect!
    var menuShown = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // FOR SCREEN SIZE-DEPENDENT MENU WIDTH
        screenSize = UIScreen.mainScreen().bounds
        
        self.configureContentViewController()
        self.configureMenuViewController()
        
        // self.tapGestureRecognizer.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: Observers & Container View Configuration
    
    // Observer method
    var contentViewController: UIViewController? {
        didSet {
            //print("CONTENT VIEW CONFIG")
            configureContentViewController()
        }
    }
    
    // Observer method
    var menuViewController: UIViewController? {
        didSet {
            
           // print("MENU VIEW CONFIG")
            configureMenuViewController()
        }
    }
    
    func configureContentViewController() {
        if self.contentView != nil {
            self.contentViewController!.view.frame = contentView.bounds
            for subview in self.contentView.subviews {
                subview.removeFromSuperview()
            }
            self.contentView.addSubview(self.contentViewController!.view)
            
            self.hideMenu()
        }
    }
    
    func configureMenuViewController() {
        if self.menuView != nil {
            self.menuViewController!.view.frame = menuView.bounds
            for subview in self.menuView.subviews {
                subview.removeFromSuperview()
            }
            self.menuView.addSubview(menuViewController!.view)
        }
    }
}


// MARK: - Helpers

extension HamburgerViewController {
    func showMenu() {
        UIView.animateWithDuration(0.35, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0, options: [], animations: { () -> Void in
            self.contentView.frame.origin = CGPoint(x: 280, y: 0)
            }, completion: { (finished: Bool) -> Void in
                self.menuShown = true
                self.tapGestureRecognizer.enabled = true
                for subview in self.contentView.subviews {
                    subview.userInteractionEnabled = false
                }
                // self.performSelector(#selector(self.hideStatusBar), withObject: self, afterDelay: 10)
        })
    }
    
    
    func hideMenu() {
        UIView.animateWithDuration(0.35, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0, options: [], animations: { () -> Void in
            self.contentView.frame.origin = CGPoint(x: 0, y: 0)
            }, completion: { (finished: Bool) -> Void in
                if !self.contentViewController!.isKindOfClass(EditableProfileViewController) {
                    UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: .Slide)
                }
                self.menuShown = false
                self.tapGestureRecognizer.enabled = false
                for subview in self.contentView.subviews {
                    subview.userInteractionEnabled = true
                }
        })
    }
    
    func showOrHideMenu() {
        if self.menuShown {
            self.hideMenu()
        } else {
            self.showMenu()
        }
    }
    
    func hideStatusBar() {
        UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: .None)
    }
}


// MARK: - Gesture Recognizer Delegate

//extension HamburgerViewController: UIGestureRecognizerDelegate {
//    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
//        return true
//    }
//}


// MARK: - Actions

extension HamburgerViewController {
    @IBAction func onPanGesture(sender: UIPanGestureRecognizer) {
        let translation = sender.translationInView(view)
        let velocity = sender.velocityInView(view)
        
        if sender.state == UIGestureRecognizerState.Began {
            UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: .Slide)
            contentViewOriginalOrigin = contentView.frame.origin
        } else if sender.state == UIGestureRecognizerState.Changed {
            
            // enables sliding in both directions (adding negative translation when going to the left)
            let newX = contentViewOriginalOrigin.x + translation.x
            if newX < 0 {
                contentView.frame.origin.x = 0.01 * newX
            } else {
                contentView.frame.origin.x =  newX
            }
            
        } else if sender.state == UIGestureRecognizerState.Ended {
            if velocity.x > 0 {
                self.showMenu()
                self.view.endEditing(true)
            } else {
                self.hideMenu()
            }
        }
    }
    
    @IBAction func onContentViewTapped(sender: AnyObject) {
        print("CONTENT VIEW TAPED")
        self.hideMenu()
    }
}
