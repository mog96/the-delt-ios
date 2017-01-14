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
    @IBOutlet weak var deltView: DeltLoadingView!
    
    @IBOutlet var panGestureRecognizer: UIPanGestureRecognizer!
    @IBOutlet var tapGestureRecognizer: UITapGestureRecognizer!
    
    let xThreshold = 100
    var contentViewOriginalOrigin: CGPoint!
    var screenSize: CGRect!
    var menuShown = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // FOR SCREEN SIZE-DEPENDENT MENU WIDTH
        self.screenSize = UIScreen.main.bounds
        
        self.configureContentViewController()
        self.configureMenuViewController()
        
        self.deltView.deltColor = UIColor.black
        self.deltView.deltColorSet = [.black, .white, .red, .blue]
        self.deltView.deltRepeatInterval = 0.05
        self.deltView.deltFadeDuration = 0.3
        self.deltView.isHidden = true
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
        UIView.animate(withDuration: 0.35, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0, options: [], animations: { () -> Void in
            self.contentView.frame.origin = CGPoint(x: 280, y: 0)
            }, completion: { (finished: Bool) -> Void in
                self.menuShown = true
                self.tapGestureRecognizer.isEnabled = true
                for subview in self.contentView.subviews {
                    subview.isUserInteractionEnabled = false
                }
                // self.performSelector(#selector(self.hideStatusBar), withObject: self, afterDelay: 10)
        })
    }
    
    
    func hideMenu() {
        UIView.animate(withDuration: 0.35, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0, options: [], animations: { () -> Void in
            self.contentView.frame.origin = CGPoint(x: 0, y: 0)
            }, completion: { (finished: Bool) -> Void in
                if !self.contentViewController!.isKind(of: EditableProfileViewController.self) {
                    UIApplication.shared.setStatusBarHidden(false, with: .slide)
                }
                self.menuShown = false
                self.tapGestureRecognizer.isEnabled = false
                for subview in self.contentView.subviews {
                    subview.isUserInteractionEnabled = true
                }
                self.deltView.stopAnimating()
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
        UIApplication.shared.setStatusBarHidden(true, with: .none)
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
    @IBAction func onPanGesture(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: view)
        let velocity = sender.velocity(in: view)
        
        if sender.state == UIGestureRecognizerState.began {
            UIApplication.shared.setStatusBarHidden(true, with: .slide)
            contentViewOriginalOrigin = contentView.frame.origin
        } else if sender.state == UIGestureRecognizerState.changed {
            
            // enables sliding in both directions (adding negative translation when going to the left)
            let newX = contentViewOriginalOrigin.x + translation.x
            if newX < 0 {
                contentView.frame.origin.x = 0.01 * newX
            } else {
                contentView.frame.origin.x =  newX
            }
            
        } else if sender.state == UIGestureRecognizerState.ended {
            if velocity.x > 0 {
                self.showMenu()
                self.view.endEditing(true)
            } else {
                self.hideMenu()
            }
        }
    }
    
    @IBAction func onContentViewTapped(_ sender: AnyObject) {
        print("CONTENT VIEW TAPED")
        self.hideMenu()
    }
}
