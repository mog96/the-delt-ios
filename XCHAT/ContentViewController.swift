//
//  ContentViewController.swift
//  XCHAT
//
//  Created by Mateo Garcia on 1/18/16.
//  Copyright © 2016 Mateo Garcia. All rights reserved.
//

import UIKit
import Parse

class ContentViewController: UIViewController {
    
    var appDelegate: AppDelegate!
    var menuShown = false
    
    var menuDelegate: MenuDelegate!
    var hamburgerViewController: HamburgerViewController!
    
    override func viewDidLoad() {
        self.appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    }
    
    override func viewWillAppear(animated: Bool) {
        // For when profile vc is presented.
        self.navigationController?.navigationBar.setBackgroundImage(nil, forBarMetrics: .Default)
        self.navigationController?.navigationBar.shadowImage = nil
    }
}


// MARK: - Helpers

extension ContentViewController {
    func setMenuButton(withColor color: String) {
        let menuButton = UIButton(type: UIButtonType.Custom)
        let menuImage = UIImage(named: "menu_icon_" + color + ".png")
        menuButton.setImage(menuImage, forState: UIControlState.Normal)
        menuButton.frame = CGRectMake(5, 0, 17, 11)
        menuButton.addTarget(self, action: #selector(ContentViewController.menuTapped), forControlEvents: UIControlEvents.TouchUpInside)
        
        let menuBarButton = UIBarButtonItem(customView: menuButton)
        self.navigationItem.leftBarButtonItem = menuBarButton
    }
    
    func menuTapped() {
        
        print("MENU TAPPED")
        
        self.menuDelegate.menuButtonTapped()
    }
}


// MARK: - Profile Presenter Delegate

extension ContentViewController: ProfilePresenterDelegate {
    func profilePresenter(wasTappedWithUser user: PFUser?) {
        let storyboard = UIStoryboard(name: "Profile", bundle: nil)
        let profileVC = storyboard.instantiateViewControllerWithIdentifier("EditableProfileViewController") as! EditableProfileViewController
        profileVC.editable = false
        profileVC.user = user
        self.navigationController?.pushViewController(profileVC, animated: true)
    }
    
    func profilePresenter(wasTappedWithUsername username: String?) {
        let storyboard = UIStoryboard(name: "Profile", bundle: nil)
        let profileVC = storyboard.instantiateViewControllerWithIdentifier("EditableProfileViewController") as! EditableProfileViewController
        profileVC.editable = false
        profileVC.username = username
        self.navigationController?.pushViewController(profileVC, animated: true)
    }
}
