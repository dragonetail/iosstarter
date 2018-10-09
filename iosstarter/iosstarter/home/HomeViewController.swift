//
//  ViewController.swift
//  iosstarter
//
//  Created by 孙玉新 on 2018/9/27.
//  Copyright © 2018年 dragonetail. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func localPhotoGalleryTapped(_ sender: Any) {
        print("test...")
        
        let localPhotoGalleryViewController = LocalPhotoGalleryViewController()
        //    vc.imgArray = self.imageArray
        //    vc.passedContentOffset = indexPath
        self.navigationController?.pushViewController(localPhotoGalleryViewController, animated: true)
    }
}

