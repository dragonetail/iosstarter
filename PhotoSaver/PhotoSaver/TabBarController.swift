//
//  TabBarController.swift
//  PhotoSaver
//
//  Created by 孙玉新 on 2018/10/9.
//  Copyright © 2018年 dragonetail. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let localPhotoGalleryController = LocalPhotoGalleryController()
        localPhotoGalleryController.tabBarItem = UITabBarItem(tabBarSystemItem: .search, tag: 0)
        
        
        let cloudPhotoViewController = LocalPhotoGalleryController()
        cloudPhotoViewController.tabBarItem = UITabBarItem(tabBarSystemItem: .more, tag: 1)
        
        
        let transferViewController = LocalPhotoGalleryController()
        transferViewController.tabBarItem = UITabBarItem(tabBarSystemItem: .featured, tag: 1)
        
        let configViewController = LocalPhotoGalleryController()
        configViewController.tabBarItem = UITabBarItem(tabBarSystemItem: .featured, tag: 1)
        
        
        let tabBarList = [localPhotoGalleryController, cloudPhotoViewController, transferViewController, configViewController]
        

        viewControllers = tabBarList
    }
}
