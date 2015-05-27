    //
//  HamburgerViewController.swift
//  chirpin
//
//  Created by Mateo Garcia on 5/6/15.
//  Copyright (c) 2015 Mateo Garcia. All rights reserved.
//

import UIKit

class HamburgerViewController: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var contentView: UIView!
    
    let xThreshold = 100
    var contentViewOriginalOrigin: CGPoint!
    
    // MARK: Observers & Container View Configuration
    
    // Observer method
    var contentViewController: UIViewController? {
        didSet {
            //println("CONTENT VIEW CONFIG")
            configureContentViewController()
        }
    }
    
    // Observer method
    var menuViewController: UIViewController? {
        didSet {
           // println("MENU VIEW CONFIG")
            configureMenuViewController()
        }
    }
    
    func configureContentViewController() {
        if contentView != nil {
            //println("CONTENT SUCCESS")
            contentViewController!.view.frame = contentView.bounds
            for subview in contentView.subviews {
                subview.removeFromSuperview()
            }
            contentView.addSubview(contentViewController!.view)
            
            // animates menu closing when new contentView set
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.contentView.frame.origin = CGPoint(x: 0, y: 0)
            })
            var tapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("handleTap:"))
            tapGestureRecognizer.numberOfTapsRequired = 2
            tapGestureRecognizer.delegate = self
            self.view.addGestureRecognizer(tapGestureRecognizer)
            
        }
    }
    
    func handleTap(recognizer: UITapGestureRecognizer){
        hideMenu()
    }
    
    func configureMenuViewController() {
        if menuView != nil {
            //println("MENU SUCCESS")
            menuViewController!.view.frame = menuView.bounds
            for subview in menuView.subviews {
                subview.removeFromSuperview()
            }
            menuView.addSubview(menuViewController!.view)
        }
    }
    
    // MARK: Required

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureContentViewController()
        configureMenuViewController()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Actions
    
    func showMenu(){
            UIView.animateWithDuration(0.35, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0, options: nil, animations: { () -> Void in
                self.contentView.frame.origin = CGPoint(x: 280, y: 0)
                }, completion: { (finished: Bool) -> Void in
            })
    }
    

    func hideMenu(){
        UIView.animateWithDuration(0.35, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0, options: nil, animations: { () -> Void in
            self.contentView.frame.origin = CGPoint(x: 0, y: 0)
            }, completion: { (finished: Bool) -> Void in
        })
    }
    
    @IBAction func onPanGesture(sender: UIPanGestureRecognizer) {
        var translation = sender.translationInView(view)
        var velocity = sender.velocityInView(view)
        
        //println("PAN GESTURE DETECTED")
        
        if sender.state == UIGestureRecognizerState.Began {
            contentViewOriginalOrigin = contentView.frame.origin
        } else if sender.state == UIGestureRecognizerState.Changed {
            
            // enables sliding in both directions (adding negative translation when going to the left)
            var newx = contentViewOriginalOrigin.x + translation.x
            if newx < 0{
                contentView.frame.origin.x = 0.01 * newx
            }
            else{
                contentView.frame.origin.x =  newx
            }
            


        } else if sender.state == UIGestureRecognizerState.Ended {
            if velocity.x > 0 {
                showMenu()
                self.view.endEditing(true)
            } else {
                hideMenu()
                

            }
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
