//
//  ContentViewController.swift
//  XCHAT
//
//  Created by Mateo Garcia on 1/18/16.
//  Copyright © 2016 Mateo Garcia. All rights reserved.
//

import UIKit

class ContentViewController: UIViewController {
    
    var appDelegate: AppDelegate!
    var menuShown = false
    
    var menuDelegate: MenuDelegate!
    
    override func viewDidLoad() {
        self.appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    }
    
    func setMenuButton(withColor color: String) {
        let menuButton = UIButton(type: UIButtonType.Custom)
        let menuImage = UIImage(named: "menu_icon_" + color + ".png")
        menuButton.setImage(menuImage, forState: UIControlState.Normal)
        menuButton.frame = CGRectMake(5, 0, 17, 11)
        menuButton.addTarget(self, action: "menuTapped", forControlEvents: UIControlEvents.TouchUpInside)
        
        let menuBarButton = UIBarButtonItem(customView: menuButton)
        self.navigationItem.leftBarButtonItem = menuBarButton
    }
    
    func menuTapped() {
        
        print("MENU TAPPED")
        
        self.menuDelegate.menuButtonTapped()
    }
}
