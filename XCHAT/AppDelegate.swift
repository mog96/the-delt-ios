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
    var hamburgerViewController: HamburgerViewController!
    var menuViewController: MenuViewController!
    
    static var appName = "the delt."
    static var allowRotation = false
    static var isAdmin = true

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        AppDelegate.appName = NSBundle.mainBundle().infoDictionary!["CFBundleDisplayName"] as! String
        
        var keys: NSDictionary?
        if let path = NSBundle.mainBundle().pathForResource("Keys", ofType: "plist") {
            keys = NSDictionary(contentsOfFile: path)
        }
        
        // Parse config.
        if let _ = keys {
            let configuration = ParseClientConfiguration {
                $0.applicationId = keys!["parseApplicationId"] as? String
                $0.clientKey = keys!["parseClientKey"] as? String
                #if TARGET_IPHONE_SIMULATOR
                    $0.server = "http://localhost:1337/parse"
                #else
                    $0.server = "http://mog.local:1337/parse"
                #endif
                //$0.server = "http://thedelt.herokuapp.com/parse"
            }
            Parse.initializeWithConfiguration(configuration)
            
            PFUser.enableRevocableSessionInBackgroundWithBlock { (error: NSError?) -> Void in
                print("enableRevocableSessionInBackgroundWithBlock completion")
            }
            
        } else {
            print("Error: Unable to load Keys.plist.")
        }
        
        // Set up hamburger menu.
        let menuStoryboard = UIStoryboard(name: "Menu", bundle: nil)
        self.hamburgerViewController = menuStoryboard.instantiateViewControllerWithIdentifier("HamburgerViewController") as! HamburgerViewController
        self.menuViewController = menuStoryboard.instantiateViewControllerWithIdentifier("MenuViewController") as! MenuViewController
        self.hamburgerViewController!.menuViewController = self.menuViewController
        self.menuViewController.hamburgerViewController = hamburgerViewController
        
        // ** SETS START VIEW **
        // Set up initial view (REEL).
        let initialStoryboard = UIStoryboard(name: "Reel", bundle: nil)
        let initialNavigationController = initialStoryboard.instantiateViewControllerWithIdentifier("ReelNavigationController") as! UINavigationController
        self.hamburgerViewController!.contentViewController = initialNavigationController
        let reelViewController = initialNavigationController.viewControllers[0] as! ReelViewController
        reelViewController.menuDelegate = self.menuViewController
        
        /*
        // Set up Reachability.
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
        
        // Check if user is logged in.
        if PFUser.currentUser() == nil {
            
            // START HERE: present login.
            
            print("DOOKIE")
            
            let loginStoryboard = UIStoryboard(name: "Login", bundle: nil)
            let loginViewController = loginStoryboard.instantiateViewControllerWithIdentifier("LoginViewController") as! LoginViewController
            
            // Does exactly the same as arrow in storyboard. ("100% parity." --Tim Lee)
            window?.rootViewController = loginViewController
            
        } else {
            
            // Does exactly the same as arrow in storyboard. ("100% parity." --Tim Lee)
            window?.rootViewController = self.hamburgerViewController
        }
        
        
        
        
        
        // Override point for customization after application launch.
        // NSNotificationCenter.defaultCenter().addObserver(self, selector: "userDidLogout", name: userDidLogoutNotification, object: nil)
        
        
        //****** DEPRECATED ******
        //if we want to read from a file called Credentials.plist
        //if let path=NSBundle.mainBundle().pathForResource("Credentials", ofType: "plist") {
            //var myDict = NSDictionary(contentsOfFile: path)
            //let appId = myDict!.valueForKey("appId") as! NSString
            //let clientKey = myDict!.valueForKey("clientKey")as! NSString
        
        /*
        // PUSH STUFF
        let appId = "cEpg8HAH75eVLcqfp9VfbQIdUJ1lz7XVMwrZ5EYc"
        let clientKey = "Ldbj47H9IXlzbIKkW1W7DkK2YvbeAfdCTVyregTL"
        Parse.setApplicationId(appId as String,
            clientKey: clientKey as String)
        
        // Register for Push Notitications
        if application.applicationState != UIApplicationState.Background {
            // Track an app open here if we launch with a push, unless
            // "content_available" was used to trigger a background push (introduced in iOS 7).
            // In that case, we skip tracking here to avoid double counting the app-open.
            
            let preBackgroundPush = !application.respondsToSelector("backgroundRefreshStatus")
            let oldPushHandlerOnly = !self.respondsToSelector("application:didReceiveRemoteNotification:fetchCompletionHandler:")
            var pushPayload = false
            if let options = launchOptions {
                pushPayload = options[UIApplicationLaunchOptionsRemoteNotificationKey] != nil
            }
            if (preBackgroundPush || oldPushHandlerOnly || pushPayload) {
                PFAnalytics.trackAppOpenedWithLaunchOptionsInBackground(launchOptions, block: nil)
                //                        .trackAppOpenedWithLaunchOptions(launchOptions)
            }
        }
        
        if application.respondsToSelector("registerUserNotificationSettings:") {
            let userNotificationTypes = UIUserNotificationType.Alert | UIUserNotificationType.Badge | UIUserNotificationType.Sound
            let settings = UIUserNotificationSettings(forTypes: userNotificationTypes, categories: nil)
            application.registerUserNotificationSettings(settings)
            application.registerForRemoteNotifications()
        } else {
            let types = UIRemoteNotificationType.Badge | UIRemoteNotificationType.Alert | UIRemoteNotificationType.Sound
            application.registerForRemoteNotificationTypes(types)
        }
        */
        
        return true
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        /*
        let installation = PFInstallation.currentInstallation()
        installation.setDeviceTokenFromData(deviceToken)
        //there's no empty saveInBackground method
        installation.saveInBackgroundWithBlock { (success:Bool, error:NSError?) -> Void in
                       //nothing here for callback
        }
        */
    }
    
            
   
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        /*
        if error.code == 3010 {
            print("Push notifications are not supported in the iOS Simulator.")
        } else {
            print("application:didFailToRegisterForRemoteNotificationsWithError: %@", error)
        }
        */
    }

        
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        /*
        PFPush.handlePush(userInfo)
        if application.applicationState == UIApplicationState.Inactive {
            PFAnalytics.trackAppOpenedWithRemoteNotificationPayloadInBackground(userInfo, block: { (success:Bool, error:NSError?) -> Void in
                //nothing here for callback

            })
        }
        */
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
}

