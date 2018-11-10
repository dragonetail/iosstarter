//
//  ImageSection.swift
//  PhotoSaver
//
//  Created by 孙玉新 on 2018/10/26.
//  Copyright © 2018年 dragonetail. All rights reserved.
//

import Foundation

class ImageSection {
    var images = [Image]()
    var count: Int  = 0
    var isSelected: Bool  = false
    let groupedDate: String
    
    init(groupedDate: String) {
        self.groupedDate = groupedDate
    }
}
