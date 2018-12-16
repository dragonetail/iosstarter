//
//  File.swift
//  PhotoSaver
//
//  Created by dragonetail on 2018/12/16.
//  Copyright © 2018 dragonetail. All rights reserved.
//

import UIKit

struct OrientationUtils {
    static func isLandscape() -> Bool {
        return currentOrientation().isLandscape
    }

    static func currentOrientation() -> UIInterfaceOrientation {
        switch UIDevice.current.orientation {
        case .portrait:
            return UIInterfaceOrientation.portrait
        case .portraitUpsideDown:
            return UIInterfaceOrientation.portraitUpsideDown
        case .landscapeLeft:
            return UIInterfaceOrientation.landscapeLeft
        case .landscapeRight:
            return UIInterfaceOrientation.landscapeRight
        default:
            return UIApplication.shared.statusBarOrientation
        }
    }
}
