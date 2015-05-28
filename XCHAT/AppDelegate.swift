//
//  AppDelegate.swift
//  XCHAT
//
//  Created by Mateo Garcia on 5/12/15.
//  Copyright (c) 2015 Mateo Garcia. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var storyboard = UIStoryboard(name: "Main", bundle: nil)
    var chat_storyboard = UIStoryboard(name: "Chat", bundle: nil)
    var hamburgerViewController: HamburgerViewController?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        Parse.setApplicationId("cEpg8HAH75eVLcqfp9VfbQIdUJ1lz7XVMwrZ5EYc", clientKey: "Ldbj47H9IXlzbIKkW1W7DkK2YvbeAfdCTVyregTL")
        
        PFUser.enableRevocableSessionInBackgroundWithBlock { (error: NSError?) -> Void in
            println("IDK")
        }
        
        // Override point for customization after application launch.
        // NSNotificationCenter.defaultCenter().addObserver(self, selector: "userDidLogout", name: userDidLogoutNotification, object: nil)
        
        
        // IF USER IS LOGGED IN
        if PFUser.currentUser() != nil {
            
            // ** SETS START VIEW **
            hamburgerViewController = storyboard.instantiateViewControllerWithIdentifier("HamburgerViewController") as? HamburgerViewController
            var menuViewController = storyboard.instantiateViewControllerWithIdentifier("MenuViewController") as! MenuViewController
            
            var chatStoryboard = UIStoryboard(name: "Chat", bundle: nil)
            var chatNavigationController = chatStoryboard.instantiateViewControllerWithIdentifier("ChatNavigationController") as! UINavigationController
            
            // TODO: SET START VIEW TO THREADS
            hamburgerViewController!.contentViewController = chatNavigationController
            
            hamburgerViewController!.menuViewController = menuViewController
            menuViewController.hamburgerViewController = hamburgerViewController
            
            // Does exactly the same as arrow in storyboard. ("100% parity." --Tim Lee)
            window?.rootViewController = hamburgerViewController
        }
        
        
        //if we want to read from a file called Credentials.plist
        //if let path=NSBundle.mainBundle().pathForResource("Credentials", ofType: "plist") {
            //var myDict = NSDictionary(contentsOfFile: path)
            //let appId = myDict!.valueForKey("appId") as! NSString
            //let clientKey = myDict!.valueForKey("clientKey")as! NSString
        
        
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
        
        return true
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let installation = PFInstallation.currentInstallation()
        installation.setDeviceTokenFromData(deviceToken)
        //there's no empty saveInBackground method
        installation.saveInBackgroundWithBlock { (success:Bool, error:NSError?) -> Void in
                       //nothing here for callback
        }
    }
    
            
   
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        if error.code == 3010 {
            println("Push notifications are not supported in the iOS Simulator.")
        } else {
            println("application:didFailToRegisterForRemoteNotificationsWithError: %@", error)
        }
        
    }

        
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        PFPush.handlePush(userInfo)
        if application.applicationState == UIApplicationState.Inactive {
            PFAnalytics.trackAppOpenedWithRemoteNotificationPayloadInBackground(userInfo, block: { (success:Bool, error:NSError?) -> Void in
                //nothing here for callback

            })
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


}

