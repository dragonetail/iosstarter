//
//  Config.swift
//  PhotoSaver
//
//  Created by 孙玉新 on 2018/10/17.
//  Copyright © 2018年 dragonetail. All rights reserved.
//
import UIKit
import AVFoundation


public struct Config {

    public struct Grid {
        public struct CloseButton {
            public static var tintColor: UIColor = UIColor(red: 109 / 255, green: 107 / 255, blue: 132 / 255, alpha: 1)
        }

        public struct ArrowButton {
            public static var tintColor: UIColor = UIColor(red: 110 / 255, green: 117 / 255, blue: 131 / 255, alpha: 1)
        }

        

        
    }

    public struct EmptyView {
        public static var image: UIImage? = GalleryBundle.image("gallery_empty_view_image")
        public static var textColor: UIColor = UIColor(red: 102 / 255, green: 118 / 255, blue: 138 / 255, alpha: 1)
    }

    public struct Permission {
        public static var image: UIImage? = GalleryBundle.image("gallery_permission_view_camera")
        public static var textColor: UIColor = UIColor(red: 102 / 255, green: 118 / 255, blue: 138 / 255, alpha: 1)

        public struct Button {
            public static var textColor: UIColor = UIColor.white
            public static var highlightedTextColor: UIColor = UIColor.lightGray
            public static var backgroundColor = UIColor(red: 40 / 255, green: 170 / 255, blue: 236 / 255, alpha: 1)
        }
    }
    
    public struct Font {
        
        public struct Main {
            public static var light: UIFont = UIFont.systemFont(ofSize: 1)
            public static var regular: UIFont = UIFont.systemFont(ofSize: 1)
            public static var bold: UIFont = UIFont.boldSystemFont(ofSize: 1)
            public static var medium: UIFont = UIFont.boldSystemFont(ofSize: 1)
        }
        
        public struct Text {
            public static var regular: UIFont = UIFont.systemFont(ofSize: 1)
            public static var bold: UIFont = UIFont.boldSystemFont(ofSize: 1)
            public static var semibold: UIFont = UIFont.boldSystemFont(ofSize: 1)
        }
    }
}


extension Locale {
    static var current : Locale { return Locale.init(identifier: "zh_CN") }
}
