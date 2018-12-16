//
//  File.swift
//  PhotoSaver
//
//  Created by dragonetail on 2018/12/16.
//  Copyright © 2018 dragonetail. All rights reserved.
//

import Photos

struct LocalizedStringHelper {

    static func localized(_ mediaType: PHAssetMediaType, _ mediaSubtype: PHAssetMediaSubtype) -> String {
        if let mediaSubtypeStr = localized(mediaSubtype) {
            return mediaSubtypeStr
        }
        return localized(mediaType)
    }
    
    static func localized(_ mediaType: PHAssetMediaType) -> String {
        switch mediaType {
        case .image:
            return "照片"
        case .video:
            return "视频"
        case .audio:
            return "音频"
        default:
            return "未知"
        }
    }
    static func localized(_ mediaSubtype: PHAssetMediaSubtype) -> String? {
        switch mediaSubtype {
        case .photoPanorama: //1
            return "全景照片"
        case .photoHDR:  //2
            return "HDR照片"
        case .photoScreenshot: //4
            return "屏幕快照"
        case .photoLive:  //8
            return "Live照片"
        case .photoDepthEffect: //16
            return "深度照片"
        case .videoStreamed: //131072
            return "视频流"
        case .videoHighFrameRate: //131072
            return "高帧视频"
        case .videoTimelapse: //262144
            return "缩时摄影"
        default:
            return nil
        }
    }

    static func localized(_ orientation: UIImage.Orientation?) -> String {
        guard let orientation = orientation else {
            return "无旋转"
        }
        switch orientation {
        case .up:
            return "正常"
        case .down:
            return "180度旋转"
        case .left:
            return "左90度旋转"
        case .right:
            return "左90度旋转"
        case .upMirrored:
            return "镜像"
        case .downMirrored:
            return "180度旋转+镜像"
        case .leftMirrored:
            return "左90度旋转+镜像"
        case .rightMirrored:
            return "左90度旋转+镜像"
        default:
            return "无旋转"
        }
    }
    
    static func localized(_ playbackStyle: PHAsset.PlaybackStyle?) -> String? {
        guard let playbackStyle = playbackStyle else {
            return nil
        }
        switch playbackStyle {
        case .image:
            return "静态图片"
        case .imageAnimated:
            return "动画图片"
        case .livePhoto:
            return "Live照片"
        case .video:
            return "视频"
        case .videoLooping:
            return "循环视频"
        default: //unsupported
            return "未确定"
        }
    }
    
    static func localized(_ assetSourceType: PHAssetSourceType?) -> String? {
        guard let assetSourceType = assetSourceType else {
            return nil
        }
        switch assetSourceType {
        case .typeUserLibrary:
            return "用户图库"
        case .typeCloudShared:
            return "云共享库"
        case .typeiTunesSynced:
            return "iTunes同步库"
        default: //unsupported
            return "未确定"
        }
    }
}

