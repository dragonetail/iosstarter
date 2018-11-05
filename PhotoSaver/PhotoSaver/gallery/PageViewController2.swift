//
//  PageViewController.swift
//  PhotoSaver
//
//  Created by 孙玉新 on 2018/10/21.
//  Copyright © 2018年 dragonetail. All rights reserved.
//

import Foundation
import UIKit
import ATGMediaBrowser

class PageViewController2 {
    
    private var images: [Image] = []
    private var startImage: Image?
    
    func setup(images: [Image], startImage: Image) {
        self.images = images
        self.startImage = startImage
    }
}
extension PageViewController2 :MediaBrowserViewControllerDataSource{
    func numberOfItems(in mediaBrowser: MediaBrowserViewController) -> Int {
        return images.count
    }
    
    func mediaBrowser(_ mediaBrowser: MediaBrowserViewController, imageAt index: Int, completion: @escaping MediaBrowserViewControllerDataSource.CompletionBlock) {
        
        // Fetch the required image here. Pass it to the completion
        // block along with the index, zoom scale, and error if any.
        let image: Image = images[index]
        image.resolve(completion: { uiImage in
            completion(index, uiImage, ZoomScale.default, nil)
        })
    }
}
