//
//  AppDelegate.swift
//  BlendVisionLoomPlayerSample
//
//  Created by chantil on 2021/8/2.
//  Copyright © 2021 KKStream Limited. All rights reserved.
//

import UIKit
import BlendVisionLoomPlayer

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        UITabBar.appearance().tintColor = UIColor(red: 6 / 255, green: 60 / 255, blue: 230 / 255, alpha: 1)

        if #available(iOS 13.0, *) {} else {
            let viewControllers = [
                UINavigationController(rootViewController: LoomViewController(style: .grouped),
                                       title: "Loom")
            ]

            let tabBarController = UITabBarController()
            tabBarController.setViewControllers(viewControllers, animated: false)

            window = UIWindow(frame: UIScreen.main.bounds)
            window?.rootViewController = tabBarController
            window?.makeKeyAndVisible()
        }
        return true
    }

    // MARK: UISceneSession Lifecycle

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        // Return locked orientation mask if player's autorotate is disabled.
        RotationHelper.lockedOrientationMask ?? .all
    }

}

