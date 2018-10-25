//
//  AppDelegate.swift
//  UIViewsSample
//
//  Created by 孙玉新 on 2018/10/17.
//  Copyright © 2018年 dragonetail. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = ProfileViewController()
        window?.makeKeyAndVisible()
        
        return true
    }
}

