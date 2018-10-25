//
//  RunOnce.swift
//  PhotoSaver
//
//  Created by 孙玉新 on 2018/10/19.
//  Copyright © 2018年 dragonetail. All rights reserved.
//

import Foundation

class RunOnce {
    
    var already: Bool = false
    
    func run(_ block: () -> Void) {
        guard !already else { return }
        
        block()
        already = true
    }
}
