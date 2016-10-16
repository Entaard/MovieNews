//
//  AppDelegate.swift
//  MovieNews
//
//  Created by Enta'ard on 10/11/16.
//  Copyright © 2016 Enta'ard. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let newWidth = CGFloat(30)

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // Find Main.storyboard
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        // init navigation controller and its subview (the MovieViewController)
        let nowPlayingController = mainStoryboard.instantiateViewController(withIdentifier: "NavMovieViewController")
        nowPlayingController.tabBarItem.title = "Now Playing"
        nowPlayingController.tabBarItem.image = resizeImage(image: UIImage(named: "now-playing")!, newWidth: newWidth)

        // init top rating view controller
        let topRatingController = mainStoryboard.instantiateViewController(withIdentifier: "NavTopRatedViewController")
        topRatingController.tabBarItem.title = "Top Rated"
        topRatingController.tabBarItem.image = resizeImage(image: UIImage(named: "top-rated")!, newWidth: newWidth)
        
        // Set up the Tab Bar Controller to have two tabs
        let tabBarController = UITabBarController()
        tabBarController.viewControllers = [nowPlayingController, topRatingController]
        tabBarController.tabBar.tintColor = UIColor(colorLiteralRed: 255, green: 0, blue: 255, alpha: 1)
        
        // Make the Tab Bar Controller the root view controller
        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()
        
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

    private func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
}

