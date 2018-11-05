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

        if Permission.Photos.status == .notDetermined {
            Permission.Photos.request { //[weak self] in
                //self?.check()
            }
        }
        if Permission.Photos.status == .authorized {
            let localPhotoGalleryController = PhotoGalleryController()
            localPhotoGalleryController.title = "Gallery.Images.Title"._localize(fallback: "PHOTOS")
            localPhotoGalleryController.tabBarItem = UITabBarItem(tabBarSystemItem: .search, tag: 0)
            
            
            let cloudPhotoViewController = PhotoGalleryController()
            cloudPhotoViewController.title = "Gallery.Images.Title"._localize(fallback: "PHOTOS")
            cloudPhotoViewController.tabBarItem = UITabBarItem(tabBarSystemItem: .more, tag: 1)
            
            
            let transferViewController = PhotoGalleryController()
            transferViewController.title = "Gallery.Images.Title"._localize(fallback: "PHOTOS")
            transferViewController.tabBarItem = UITabBarItem(tabBarSystemItem: .featured, tag: 1)
            
            let configViewController = PhotoGalleryController()
            configViewController.title = "Gallery.Images.Title"._localize(fallback: "PHOTOS")
            configViewController.tabBarItem = UITabBarItem(tabBarSystemItem: .featured, tag: 1)
            
            
            let tabBarList = [localPhotoGalleryController, cloudPhotoViewController, transferViewController, configViewController]
            
            
            viewControllers = tabBarList
        }else{
            print("没有获取用户访问相册的授权")
        }
    }
}

