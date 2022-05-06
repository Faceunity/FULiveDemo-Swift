//
//  AppDelegate.swift
//  FULiveDemo-Swift
//
//  Created by 项林平 on 2022/4/6.
//

import UIKit
import FURenderKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = .white;
        window?.makeKeyAndVisible()
        let navigation = HomepageNavigationController.init(rootViewController: HomepageViewController())
        window?.rootViewController = navigation
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        FURenderKit.share().pause = true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        FURenderKit.share().pause = false
    }
}

