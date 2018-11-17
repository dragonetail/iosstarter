//
//  ImageSection.swift
//  PhotoSaver
//
//  Created by 孙玉新 on 2018/10/26.
//  Copyright © 2018年 dragonetail. All rights reserved.
//

import Foundation
import RealmSwift

class ImageSection: Object {
    @objc dynamic var groupedDate: String = ""
    let images = List<Image>()
    @objc dynamic var count: Int = 0

    var isSelected: Bool = false


    override static func primaryKey() -> String? {
        return "groupedDate"
    }
    override static func ignoredProperties() -> [String] {
        return ["isSelected"]
    }

    func save() {
        let realm = RealmManager.shared.realm
        
        try! realm.write {
            realm.add(self, update: true)
        }
    }

    static func build(groupedDate: String) -> ImageSection {
        let imageSection: ImageSection = ImageSection()
        imageSection.groupedDate = groupedDate
        imageSection.count = 0
        return imageSection
    }

}
