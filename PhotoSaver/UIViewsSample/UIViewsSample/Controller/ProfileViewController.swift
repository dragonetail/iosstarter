//
//  UIViewController.swift
//  UIViewsSample
//
//  Created by 孙玉新 on 2018/10/17.
//  Copyright © 2018年 dragonetail. All rights reserved.
//
import UIKit

class ProfileViewController: UIViewController {
    var profile: ProfileView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profile = ProfileView(frame: CGRect.zero)
        self.view.addSubview(profile)
        
        // AutoLayout
        profile.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets.zero)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
