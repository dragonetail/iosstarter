//
//  EventBus.swift
//  PhotoSaver
//
//  Created by 孙玉新 on 2018/10/20.
//  Copyright © 2018年 dragonetail. All rights reserved.
//

import Foundation
import SwiftEventBus

let eventBus = EventBus()

class EventBus {
    fileprivate init() {
    }
    
//    func bind2Main(_ eventName: String, optional ){
//        SwiftEventBus.unregister(self)
//    }
    
//    func bindSelectAlbum(_ selectAlbum: @escaping (Album)->()){
//        SwiftEventBus.onMainThread(self, name: "selectAlbum") { result in
//            let album : Album = result!.object as! Album
//            selectAlbum(album)
//        }
//    }
//
//    func triggerSelectAlbum(_ album: Album){
//        SwiftEventBus.postToMainThread("selectAlbum", sender: album)
//    }
    
//    func bindPageShowImages(_ pageShowImages: @escaping (Album, IndexPath)->()){
//        SwiftEventBus.onMainThread(self, name: "pageShowImages") { result in
//            let data = result!.object as! (album: Album, indexPath: IndexPath)
//            pageShowImages(data.album, data.indexPath)
//        }
//    }
//    
//    func triggerPageShowImages(album: Album, indexPath: IndexPath){
//        SwiftEventBus.postToMainThread("pageShowImages", sender: (album: album, indexPath: indexPath))
//    }
//    
//    func unbindAll(){
//        SwiftEventBus.unregister(self)
//    }
    
}



//SwiftEventBus.onMainThread(target, name: "someEventName") { result in
//    // UI thread
//}
//
//// or
//
//SwiftEventBus.onBackgroundThread(target, name:"someEventName") { result in
//    // API Access
//}
//
//SwiftEventBus.post("someEventName")
//
//SwiftEventBus.post("personFetchEvent", sender: Person(name:"john doe"))
//
//SwiftEventBus.onMainThread(target, name:"personFetchEvent") { result in
//    let person : Person = result.object as Person
//    println(person.name) // will output "john doe"
//}
//
//SwiftEventBus.unregister(target, "someEventName")


