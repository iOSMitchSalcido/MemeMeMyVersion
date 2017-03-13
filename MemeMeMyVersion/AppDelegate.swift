//
//  AppDelegate.swift
//  MemeMeMyVersion
//
//  Created by Online Training on 3/6/17.
//  Copyright © 2017 Mitch Salcido. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    // saved Memes
    var memeStore = [Meme]()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // debug Memes...
        for i in 0..<3 {
            
            let originalImage = UIImage(named: "CreateMeme")
            let memedImage = UIImage(named: "CreateMeme")
            let attribute = [NSStrokeColorAttributeName: UIColor.white,
                             NSStrokeWidthAttributeName: NSNumber(value: 0.0),
                             NSForegroundColorAttributeName: UIColor.white,
                             NSFontAttributeName: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!]
            let meme = Meme(topText: "Meme #\(i)",
                bottomText: "This is Meme number \(i)",
                textAttributes: attribute,
                originalImage: originalImage!,
                memedImage: memedImage!)
            
            memeStore.append(meme)
        }
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

