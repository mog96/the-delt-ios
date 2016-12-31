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
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?
    var hamburgerViewController: HamburgerViewController?
    var menuViewController: MenuViewController?
    
    static var appName = "the delt."
    static var allowRotation = false
    static var isAdmin = false {
        didSet {
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
            appDelegate?.menuViewController?.checkAdmin()
        }
    }
    enum ShortcutIdentifier: String {
        case Post
        case Chat
        case Calendar // case Alert
        init?(fullIdentifier: String) {
            guard let suffix = fullIdentifier.components(separatedBy: ".").last else {
                return nil
            }
            self.init(rawValue: suffix)
        }
    }
    enum PushIdentifier: String {
        case Reel
        case Alert
        case Chat
        case Calendar
        init?(fullIdentifier: String) {
            guard let suffix = fullIdentifier.components(separatedBy: ".").last else {
                return nil
            }
            self.init(rawValue: suffix)
        }
    }
    
    /**
        @param launchOptions Contains push notification if your app wasn’t running and the user launches it by tapping the push notification.
    */
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        AppDelegate.appName = Bundle.main.infoDictionary!["CFBundleDisplayName"] as! String
        
        /** CONNECT TO PARSE **/
        
        if let keys = NSDictionary(contentsOfFile: Bundle.main.path(forResource: "Keys", ofType: "plist")!) {
            // Parse config.
            let configuration = ParseClientConfiguration {
                $0.applicationId = keys["ParseApplicationID"] as? String
                $0.clientKey = keys["ParseClientKey"] as? String
                
                /* DEVELOPMENT ONLY */
                #if TARGET_IPHONE_SIMULATOR
                    $0.server = "http://localhost:1337/parse"
                #else
                    $0.server = "http://mog.local:1337/parse"
                    // $0.server = "http://192.168.1.243:1337/parse"
                #endif
                /* END DEVELOPMENT ONLY */
                
                /*********** ENABLE BEFORE APP DEPLOY ***********/
                $0.server = "https://thedelt.herokuapp.com/parse"
            }
            Parse.enableDataSharing(withApplicationGroupIdentifier: "group.com.tdx.thedelt")
            Parse.enableLocalDatastore()
            Parse.initialize(with: configuration)
            
            PFUser.enableRevocableSessionInBackground { (error: Error?) -> Void in
                print("enableRevocableSessionInBackgroundWithBlock completion")
            }
            
            // SoundCloud config.
            // Soundcloud.clientIdentifier = "COOL"
            // let soundcloud = Soundcloud()
            // Soundcloud.clientIdentifier = keys["soundCloudClientID"] as String
            
        } else {
            print("Error: Unable to load Keys.plist.")
        }
        
        /** TODO: USE REACHABILITY TO DETECT NETWORK CONNECTION **/
        
        /*
        // Set up Reachability. TODO: Present using Whisper...
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
        
        // Set up hamburger menu.
        let menuStoryboard = UIStoryboard(name: "Menu", bundle: nil)
        self.hamburgerViewController = menuStoryboard.instantiateViewController(withIdentifier: "HamburgerViewController") as? HamburgerViewController
        self.menuViewController = menuStoryboard.instantiateViewController(withIdentifier: "MenuViewController") as? MenuViewController
        self.hamburgerViewController!.menuViewController = self.menuViewController
        self.menuViewController?.hamburgerViewController = hamburgerViewController
        
        // Set initial view to Reel.
        let storyboard = UIStoryboard(name: "Reel", bundle: nil)
        let reelNC = storyboard.instantiateViewController(withIdentifier: "ReelNavigationController") as! UINavigationController
        self.hamburgerViewController!.contentViewController = reelNC
        let reelVC = reelNC.viewControllers[0] as! ReelViewController
        reelVC.menuDelegate = self.menuViewController
        
        /** CHECK IF USER LOGGED IN **/
        
        if PFUser.current() == nil {
            let loginStoryboard = UIStoryboard(name: "Login", bundle: nil)
            let loginViewController = loginStoryboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
            
            // Does exactly the same as arrow in storyboard. ("100% parity." --Tim Lee)
            window?.rootViewController = loginViewController
            // Will register for push after successful login.
            
        } else {
            // Register for push.
            AppDelegate.registerForPushNotifications(application)
            
            // Save username to NSUserDefaults in case PFUser.currentUser() fails in share extension.
            UserDefaults(suiteName: "group.com.tdx.thedelt")?.set(PFUser.current()!.username!, forKey: "Username")
            
            if let isAdmin = PFUser.current()!.object(forKey: "is_admin") as? Bool {
                AppDelegate.isAdmin = isAdmin
            } else {
                AppDelegate.isAdmin = false
            }
            
            /** HANDLE APP LAUNCH FROM NOTIFICATION **/
            
            if let notification = launchOptions?[UIApplicationLaunchOptionsKey.remoteNotification] as? [String: AnyObject] {
                print("NOTIFICATION:", notification)
                
                let aps = notification["aps"] as! [String: AnyObject]
                if let pushType = aps["pushType"] as? String {
                    if let identifier = PushIdentifier.init(fullIdentifier: pushType) {
                        switch identifier {
                        case .Reel:
                            break
                        case .Alert:
                            self.menuViewController?.presentContentView(.Alerts)
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

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        
        if AppDelegate.allowRotation {
            return [UIInterfaceOrientationMask.portrait, UIInterfaceOrientationMask.landscapeLeft, UIInterfaceOrientationMask.landscapeRight]
        }
        
        return UIInterfaceOrientationMask.portrait
    }
    
    @available(iOS 9.0, *)
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
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


// MARK: - Push Notifications

extension AppDelegate {
    static func registerForPushNotifications(_ application: UIApplication) {
        let notificationSettings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
        application.registerUserNotificationSettings(notificationSettings)
        
        print("REGISTERED FOR PUSH NOTIFICATIONS")
    }
    
    /**
     @param notificationSettings Tells us what notifications the user has allowed for our app in Settings.
     */
    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        if notificationSettings.types != UIUserNotificationType() {
            application.registerForRemoteNotifications()
        }
    }
    
    /**
     Push notification registration successful.
     */
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        /***/
        let tokenChars = (deviceToken as NSData).bytes.bindMemory(to: CChar.self, capacity: deviceToken.count)
        var tokenString = ""
        
        for i in 0..<deviceToken.count {
            tokenString += String(format: "%02.2hhx", arguments: [tokenChars[i]])
        }
        
        print("PUSH DEVICE TOKEN:", tokenString)
        /***/
        
        /** SET INSTALLATION PUSH TOKEN **/
        
        // IMPORTANT: Saves this app installation under '_Installation' collection in MongoDB.
        let installation = PFInstallation.current()!
        installation.setDeviceTokenFrom(deviceToken)
        installation.saveInBackground()
    }
    
    /**
     Push notification registration error.
     */
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        if error._code == 3010 {
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
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        print("PUSH RECEIVED!!")
        // PFPush.handlePush(userInfo)
        
        print("NOTIFICATION:", userInfo["aps"])
        
        if UIApplication.shared.applicationState != .active {
            let aps = userInfo["aps"] as! [String: AnyObject]
            if let pushType = aps["pushType"] as? String {
                guard let identifier = PushIdentifier.init(fullIdentifier: pushType) else {
                    return
                }
                let topVC = (self.hamburgerViewController?.contentViewController as? UINavigationController)?.topViewController
                switch identifier {
                case .Reel:
                    if topVC == nil || !topVC!.isKind(of: ReelViewController.self) {
                        self.menuViewController?.presentContentView(.Reel)
                    }
                case .Alert:
                    if topVC == nil || !topVC!.isKind(of: AlertsViewController.self) {
                        self.menuViewController?.presentContentView(.Alerts)
                    }
                case .Chat:
                    if topVC == nil || !topVC!.isKind(of: ChatViewController.self) {
                        self.menuViewController?.presentContentView(.Chat)
                    }
                case .Calendar:
                    if topVC == nil || !topVC!.isKind(of: CalendarViewController.self) {
                        self.menuViewController?.presentContentView(.Calendar)
                    }
                }
            }
        }
    }
    
    // @available(iOS 10.0, *)
    
}

