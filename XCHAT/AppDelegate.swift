//
//  AppDelegate.swift
//  XCHAT
//
//  Created by Mateo Garcia on 5/12/15.
//  Copyright (c) 2015 Mateo Garcia. All rights reserved.
//

import UIKit
import Parse
import Reachability

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var hamburgerViewController: HamburgerViewController?
    var menuViewController: MenuViewController?
    
    static var appName = "the delt."
    static var allowRotation = false
    static var isAdmin = false {
        didSet {
            let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate
            appDelegate?.menuViewController?.checkAdmin()
        }
    }
    
    enum ShortcutIdentifier: String {
        case Post
        case Chat
        case Calendar
        init?(fullIdentifier: String) {
            guard let suffix = fullIdentifier.componentsSeparatedByString(".").last else {
                return nil
            }
            self.init(rawValue: suffix)
        }
    }
    
    enum PushIdentifier: String {
        case Reel
        case Chat
        case Calendar
        init?(fullIdentifier: String) {
            guard let suffix = fullIdentifier.componentsSeparatedByString(".").last else {
                return nil
            }
            self.init(rawValue: suffix)
        }
    }
    
    /**
        @param launchOptions Contains push notification if your app wasn’t running and the user launches it by tapping the push notification.
    */
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        AppDelegate.appName = NSBundle.mainBundle().infoDictionary!["CFBundleDisplayName"] as! String
        
        if let keys = NSDictionary(contentsOfFile: NSBundle.mainBundle().pathForResource("Keys", ofType: "plist")!) {
            // Parse config.
            let configuration = ParseClientConfiguration {
                $0.applicationId = keys["ParseApplicationID"] as? String
                $0.clientKey = keys["ParseClientKey"] as? String
                
                // /***/
                /* DEVELOPMENT ONLY */
                #if TARGET_IPHONE_SIMULATOR
                    $0.server = "http://localhost:1337/parse"
                #else
                    $0.server = "http://mog.local:1337/parse"
                    // $0.server = "http://192.168.1.243:1337/parse"
                #endif
                /* END DEVELOPMENT ONLY */
                // */
                
                $0.server = "https://thedelt.herokuapp.com/parse"
            }
            Parse.enableDataSharingWithApplicationGroupIdentifier("group.com.tdx.thedelt")
            Parse.enableLocalDatastore()
            Parse.initializeWithConfiguration(configuration)
            
            PFUser.enableRevocableSessionInBackgroundWithBlock { (error: NSError?) -> Void in
                print("enableRevocableSessionInBackgroundWithBlock completion")
            }
            
            // SoundCloud config.
            // Soundcloud.clientIdentifier = "COOL"
            // let soundcloud = Soundcloud()
            // Soundcloud.clientIdentifier = keys["soundCloudClientID"] as String
            
        } else {
            print("Error: Unable to load Keys.plist.")
        }
        
        // TODO: MOVE
        // Register for push.
        self.registerForPushNotifications(application)
        
        // Set up hamburger menu.
        let menuStoryboard = UIStoryboard(name: "Menu", bundle: nil)
        self.hamburgerViewController = menuStoryboard.instantiateViewControllerWithIdentifier("HamburgerViewController") as? HamburgerViewController
        self.menuViewController = menuStoryboard.instantiateViewControllerWithIdentifier("MenuViewController") as? MenuViewController
        self.hamburgerViewController!.menuViewController = self.menuViewController
        self.menuViewController?.hamburgerViewController = hamburgerViewController
        
        /*
        // Set up Reachability. TODO: Use Whisper...
        let reachability = Reachability(hostName: Parse.currentConfiguration()?.server)
        reachability.unreachableBlock = { Void in
            let alertVC = UIAlertController(title: "Unable to Connect", message: "Please check your network connection", preferredStyle: .Alert)
            alertVC.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            if let currentVC = UIApplication.sharedApplication().keyWindow?.rootViewController {
                currentVC.presentViewController(alertVC, animated: true, completion: nil)
            }
            print("UNABLE TO CONNECT")
        }
        reachability.startNotifier()
        */
        
        
        /** SET DEFAULT START VIEW **/
        
        // Set initial view to Reel.
        let storyboard = UIStoryboard(name: "Reel", bundle: nil)
        let reelNC = storyboard.instantiateViewControllerWithIdentifier("ReelNavigationController") as! UINavigationController
        self.hamburgerViewController!.contentViewController = reelNC
        let reelVC = reelNC.viewControllers[0] as! ReelViewController
        reelVC.menuDelegate = self.menuViewController
        
        // Check if user is logged in.
        if PFUser.currentUser() == nil {
            let loginStoryboard = UIStoryboard(name: "Login", bundle: nil)
            let loginViewController = loginStoryboard.instantiateViewControllerWithIdentifier("LoginViewController") as! LoginViewController
            
            // Does exactly the same as arrow in storyboard. ("100% parity." --Tim Lee)
            window?.rootViewController = loginViewController
            
        } else {
            // Save username to NSUserDefaults in case PFUser.currentUser() fails in share extension.
            NSUserDefaults(suiteName: "group.com.tdx.thedelt")?.setObject(PFUser.currentUser()!.username!, forKey: "Username")
            
            if let isAdmin = PFUser.currentUser()!.objectForKey("is_admin") as? Bool {
                AppDelegate.isAdmin = isAdmin
            } else {
                AppDelegate.isAdmin = false
            }
            
            if let notification = launchOptions?[UIApplicationLaunchOptionsRemoteNotificationKey] as? [String: AnyObject] {
                print("NOTIFICATION:", notification)
                
                let aps = notification["aps"] as! [String: AnyObject]
                if let pushType = aps["pushType"] as? String {
                    if let identifier = PushIdentifier.init(fullIdentifier: pushType) {
                        switch identifier {
                        case .Reel:
                            break
                        case .Chat:
                            self.menuViewController?.presentContentView(.Chat)
                        case .Calendar:
                            self.menuViewController?.presentContentView(.Calendar)
                        }
                    }
                }
            }
            
            // Does exactly the same as arrow in storyboard. ("100% parity." --Tim Lee)
            window?.rootViewController = self.hamburgerViewController
        }
        
        return true
    }
    
    /**
        @param notificationSettings Tells us what the user has allowed for our app in Settings.
     */
    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        if notificationSettings.types != .None {
            application.registerForRemoteNotifications()
        }
    }
    
    /**
        Push notification registration successful.
     */
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        /***/
        let tokenChars = UnsafePointer<CChar>(deviceToken.bytes)
        var tokenString = ""
        
        for i in 0..<deviceToken.length {
            tokenString += String(format: "%02.2hhx", arguments: [tokenChars[i]])
        }
        
        print("PUSH DEVICE TOKEN:", tokenString)
        /***/
        
        // IMPORTANT: Saves this app installation under '_Installation' collection in MongoDB.
        let installation = PFInstallation.currentInstallation()!
        installation.setDeviceTokenFromData(deviceToken)
        installation.saveInBackground()
    }
   
    /**
        Push notification registration error.
     */
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        if error.code == 3010 {
            print("Push notifications are not supported in the iOS Simulator.")
        } else {
            print("application:didFailToRegisterForRemoteNotificationsWithError: %@", error)
        }
    }
        
    /**
        Called if your app was running and in the foreground when push notification received
        OR if your app was running or suspended in the background and the user brings it to the foreground by tapping the push notification.
     
        Use version with completion handler to do background fetching/processing on silent push received.
     */
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        print("PUSH RECEIVED!!")
        // PFPush.handlePush(userInfo)
        
        print("NOTIFICATION:", userInfo["aps"])
        
        if UIApplication.sharedApplication().applicationState != .Active {
            let aps = userInfo["aps"] as! [String: AnyObject]
            if let pushType = aps["pushType"] as? String {
                guard let identifier = PushIdentifier.init(fullIdentifier: pushType) else {
                    return
                }
                let topVC = (self.hamburgerViewController?.contentViewController as? UINavigationController)?.topViewController
                switch identifier {
                case .Reel:
                    if topVC == nil || !topVC!.isKindOfClass(ReelViewController) {
                        self.menuViewController?.presentContentView(.Reel)
                    }
                case .Chat:
                    if topVC == nil || !topVC!.isKindOfClass(ChatViewController) {
                        self.menuViewController?.presentContentView(.Chat)
                    }
                case .Calendar:
                    if topVC == nil || !topVC!.isKindOfClass(CalendarViewController) {
                        self.menuViewController?.presentContentView(.Calendar)
                    }
                }
            }
        }
    }


    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(application: UIApplication, supportedInterfaceOrientationsForWindow window: UIWindow?) -> UIInterfaceOrientationMask {
        
        if AppDelegate.allowRotation {
            return [UIInterfaceOrientationMask.Portrait, UIInterfaceOrientationMask.LandscapeLeft, UIInterfaceOrientationMask.LandscapeRight]
        }
        
        return UIInterfaceOrientationMask.Portrait
    }
    
    @available(iOS 9.0, *)
    func application(application: UIApplication, performActionForShortcutItem shortcutItem: UIApplicationShortcutItem, completionHandler: (Bool) -> Void) {
        guard let identifier = ShortcutIdentifier.init(fullIdentifier: shortcutItem.type) else {
            return
        }
        switch identifier {
        case .Post:
            self.menuViewController?.presentContentView(.Reel)
            let reelVC = (self.hamburgerViewController?.contentViewController as! UINavigationController).viewControllers[0] as! ReelViewController
            reelVC.presentImagePicker(usingPhotoLibrary: false)
        case .Chat:
            self.menuViewController?.presentContentView(.Chat)
        case .Calendar:
            self.menuViewController?.presentContentView(.Calendar)
        }
    }
}


// MARK: - Helpers

extension AppDelegate {
    func registerForPushNotifications(application: UIApplication) {
        let notificationSettings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
        application.registerUserNotificationSettings(notificationSettings)
    }
}

