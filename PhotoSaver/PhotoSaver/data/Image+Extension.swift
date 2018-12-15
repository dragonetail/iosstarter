import UIKit
import Photos
import ImageIOSwift_F2

extension Image {
    static let _palceHolder: UIImage = UIImage(named: "gallery_placeholder") ?? UIImage()
    static let _errorPalceHolder: UIImage = UIImage(named: "gallery_placeholder_for_error") ?? UIImage()

    // 使用相册的UIImage缩略图加载方法，针对View的大小进行照片加载
    func loadToImageView(_ imageView: UIImageView, defaultPlaceHolder: UIImage = _palceHolder) {
        if imageView.frame.size == CGSize.zero  {
            imageView.image = defaultPlaceHolder
            //imageView.layoutIfNeeded()
            return
        }

        let pastRequestId = imageView.tag
        if pastRequestId == 0 && imageView.image == nil {
            imageView.image = defaultPlaceHolder
            //imageView.layoutIfNeeded()
        }

        let targetSize: CGSize = imageView.frame.size
        let requestId = self.resolve(targetSize: targetSize,
                                     pastRequestId: pastRequestId,
                                     imageCallback: { (image) in
                                         let image = image ?? Image._errorPalceHolder
                                         imageView.tag = 0
                                         imageView.image = image
                                         //imageView.layoutIfNeeded()
                                     })
        imageView.tag = Int(requestId)
    }

    private func resolve(targetSize: CGSize, pastRequestId: Int? = nil, imageCallback: @escaping (UIImage?) -> Void) -> Int {
        guard let asset = PHAsset.fetchAssets(withLocalIdentifiers: [assetId], options: nil).firstObject else {
            log.warning("Couldn't get photo asset: \(assetId)")
            return 0
        }

        if let pastRequestId = pastRequestId,
            pastRequestId != 0 {
            Image.imageManager.cancelImageRequest(PHImageRequestID(pastRequestId))
        }

        let options = PHImageRequestOptions()
        options.isNetworkAccessAllowed = true
        //options.deliveryMode = .opportunistic
        options.deliveryMode = .highQualityFormat
        //        options.isSynchronous = false
        //        options.resizeMode = .fast

        let requestId = Image.imageManager.requestImage(
            for: asset,
            targetSize: targetSize,
            contentMode: .aspectFill,
            options: options)
        { (image, info) in
            // WARNING: This could fail if your phone doesn't have enough storage.
            // Since the photo is probably stored in iCloud downloading it to your phone will take most of the space left making this feature fail.
            if image == nil {
                log.warning("Couldn't get photo data for asset \(asset)")
            }

            DispatchQueue.main.async {
                imageCallback(image)
            }
        }

        return Int(requestId)
    }

    public func resolve(imageCallback: @escaping (ImageSource) -> Void, metadataCallback: ((Image) -> Void)? = nil, errorCallback: ((String) -> Void)? = nil, pastRequestId: Int? = nil) -> Int {
        guard let asset = PHAsset.fetchAssets(withLocalIdentifiers: [assetId], options: nil).firstObject else {
            return 0
        }

        if let pastRequestId = pastRequestId,
            pastRequestId != 0 {
            Image.imageManager.cancelImageRequest(PHImageRequestID(pastRequestId))
        }

        let imageRequestOptions = PHImageRequestOptions()
        imageRequestOptions.isNetworkAccessAllowed = true
        imageRequestOptions.isSynchronous = true
        imageRequestOptions.version = .original
        let requestId = Image.imageManager.requestImageData(for: asset, options: imageRequestOptions, resultHandler: { [weak self] data, dataUTI, orientation, info in
            guard let data = data,
                let info = info else {
                    let error: String = "Failed to get image data: \(self?.assetId ?? "")"
                    log.warning(error)
                    errorCallback?(error)
                    return
            }

            //let ciImg = CIImage(data: data!)
            //let imageSource = ImageSource(url: (info!["PHImageFileURLKey"] as! NSURL) as URL)
            //imageSource?.image()
            guard let imageSource = ImageSource(data: data) else {
                let error: String = "Failed to create ImageSource: \(self?.assetId ?? "")"
                log.warning(error)
                errorCallback?(error)
                return
            }

            DispatchQueue.main.async {
                imageCallback(imageSource)
            }
            DispatchQueue.main.async {
                guard let strongSelf = self else {
                    let error: String = "Image(self) was destroyed: \(self?.assetId ?? "")"
                    log.warning(error)
                    errorCallback?(error)
                    return
                }

                strongSelf.parseInfo(info)
                var metadata = strongSelf.metadata
                if metadata == nil {
                    metadata = ImageMetadata(asset)
                }

                metadata!.imageProperties = imageSource.codableProperties(at: 0)

                //                print("3 \(String(format: "%.4f", -start.timeIntervalSinceNow))s")
                //
                //                //let imageSource = ImageSource(url: (info!["PHImageFileURLKey"] as! NSURL) as URL)
                //                print("imageSource: \(metadata.imagePropertiesRawValues!.description)")
                //                print(imageSource.properties(at: 0)?.rawValue.description ?? "***")
                //
                //                print("4 \(String(format: "%.4f", -start.timeIntervalSinceNow))s")
                //
                //
                //                print("5 \(String(format: "%.4f", -start.timeIntervalSinceNow))s")
                //                let ciImg = CIImage(data: data)
                //                print("6 \(String(format: "%.4f", -start.timeIntervalSinceNow))s")
                //                print("ciImg: \(ciImg?.properties ?? [:])")

                strongSelf.metadata = metadata
                metadataCallback?(strongSelf)

                // 更新对应数据库
                DispatchQueue.global(qos: .default).async {
                    albumManager.updateImagePropeties(strongSelf)
                }
            }
        })

        return Int(requestId)
    }

    //    private func resolveImage(_ asset: PHAsset, targetSize: CGSize, imageCallback: @escaping (UIImage?) -> Void, metadataCallback: (() -> Void)? = nil) {
    //        let options = PHImageRequestOptions()
    //        options.isNetworkAccessAllowed = true
    //        //options.deliveryMode = .opportunistic
    //        options.deliveryMode = .highQualityFormat
    //        //        options.isSynchronous = false
    //        //        options.resizeMode = .fast
    //
    //        let requestId = Image.imageManager.requestImage(
    //            for: asset,
    //            targetSize: targetSize,
    //            contentMode: .aspectFill,
    //            options: options)
    //        { [weak self] (image, info) in
    //            // WARNING: This could fail if your phone doesn't have enough storage.
    //            // Since the photo is probably stored in iCloud downloading it to your phone will take most of the space left making this feature fail.
    //            if image == nil {
    //                log.warning("Couldn't get photo data for asset \(asset)")
    //            }
    //
    //            print("requestImage Data info: \(info)")
    //
    //            DispatchQueue.main.async {
    //                let imageSource = ImageSource(data: image!)
    //                imageCallback(image)
    //            }
    //
    //
    //            if let metadataCallback = metadataCallback,
    //                let strongSelf = self {
    //                DispatchQueue.global(qos: .default).async {
    //                    strongSelf.resolveImageMetadata(asset, metadataCallback)
    //                }
    //            }
    //        }
    //    }
    //    private func resolveImageMetadata(_ asset: PHAsset, _ metadataCallback: @escaping () -> Void) {
    //        var start = Date()
    //        start = Date()
    //        let imageRequestOptions = PHImageRequestOptions()
    //        imageRequestOptions.isNetworkAccessAllowed = true
    //        imageRequestOptions.isSynchronous = true
    //        imageRequestOptions.version = .original
    //        Image.imageManager.requestImageData(for: asset, options: imageRequestOptions, resultHandler: {
    //            data, dataUTI, orientation, info in
    //
    //            let ciImg = CIImage(data: data!)
    //            start = Date()
    //            let imageSource = ImageSource(data: data!)
    //            //let imageSource = ImageSource(url: (info!["PHImageFileURLKey"] as! NSURL) as URL)
    //            print("imageSource: \(imageSource?.properties()?.rawValue.description)")
    //            print(imageSource?.properties(at: 0)?.rawValue.description as! String)
    //            imageSource?.image()
    //            print("imageSource: \(String(format: "%.4f", -start.timeIntervalSinceNow))s")
    //        })
    //    }

    //    private func resolveImageMetadata(_ asset: PHAsset, _ metadataCallback: @escaping () -> Void) {
    //        print("创建日期：\(asset.creationDate!)\n"
    //            + "修改日期：\(String(describing: asset.modificationDate))\n"
    //            + "类型：\(asset.mediaType.rawValue)\n"
    //            + "子类型：\(String(describing: asset.mediaSubtypes.rawValue))\n"
    //            + "位置：\(String(describing: asset.location))\n"
    //            + "尺寸：\(String(describing: asset.pixelWidth)) x \(String(describing: asset.pixelHeight))\n"
    //            + "收藏：\(String(describing: asset.isFavorite))\n"
    //            + "burstIdentifier：\(String(describing: asset.burstIdentifier))\n"
    //            + "isHidden：\(String(describing: asset.isHidden))\n"
    //            + "sourceType(typeiTunesSynced)：\(String(describing: asset.sourceType))\n"
    //            + "debugDescription：\(String(describing: asset.debugDescription))\n"
    //            + "description：\(String(describing: asset.description))\n"
    //            + "localIdentifier：\(String(describing: asset.localIdentifier))\n"
    //            + "时长：\(asset.duration)\n")
    //
    //        print(asset.value(forKey: "filename"))
    //
    //        var start = Date()
    //        start = Date()
    //        let imageRequestOptions = PHImageRequestOptions()
    //        imageRequestOptions.isNetworkAccessAllowed = true
    //        imageRequestOptions.isSynchronous = true
    //        imageRequestOptions.version = .original
    //        Image.imageManager.requestImageData(for: asset, options: imageRequestOptions, resultHandler: {
    //            data, dataUTI, orientation, info in
    //
    //            let size = ByteCountFormatter.string(fromByteCount: Int64(data!.count), countStyle: .file)
    //            print("size: \(size)")
    //            //var message = String(format: String.localizedString(for: "FILE_SIZE"), size)
    //            //Data?, String?, UIImage.Orientation, [AnyHashable : Any]?
    //            print("dataUTI: \(dataUTI)")
    //            print("orientation: \(orientation.rawValue)")
    //            print("Data info: \(info)")
    //            print((info!["PHImageFileURLKey"] as! NSURL))
    //            print((info!["PHImageFileURLKey"] as! NSURL).lastPathComponent)
    //
    //            print("\(String(format: "%.4f", -start.timeIntervalSinceNow))s")
    //            let ciImg = CIImage(data: data!)
    //            print("\(String(format: "%.4f", -start.timeIntervalSinceNow))s")
    //            print("ciImg: \(ciImg?.properties ?? [:])")
    //
    //            start = Date()
    //            let imageSource = ImageSource(data: data!)
    //            //let imageSource = ImageSource(url: (info!["PHImageFileURLKey"] as! NSURL) as URL)
    //            print("imageSource: \(imageSource?.properties()?.rawValue.description)")
    //            print(imageSource?.properties(at: 0)?.rawValue.description as! String)
    //            imageSource?.image()
    //            print("imageSource: \(String(format: "%.4f", -start.timeIntervalSinceNow))s")
    //        })


    //        if asset.mediaType == .image {
    //            //弃用：本地模拟器文件测试情况，耗时约是上一方法的2.5倍，且没有DataInfo信息
    //            let contentEditingInputRequestOptions = PHContentEditingInputRequestOptions()
    //            contentEditingInputRequestOptions.isNetworkAccessAllowed = true
    //            asset.requestContentEditingInput(with: contentEditingInputRequestOptions, completionHandler: {
    //                (input, info) in
    //                // (PHContentEditingInput?, info: [AnyHashable : Any]
    ////                print("input: \(input!),\n info: \(info)")
    //                guard let input = input,
    //                    let url = input.fullSizeImageURL else {
    //                        return
    //                }
    ////                print("url: \(url)")
    //
    //                print("\(String(format: "%.4f", -start.timeIntervalSinceNow))s")
    //                let ciImg = CIImage(contentsOf: url)
    //                print("\(String(format: "%.4f", -start.timeIntervalSinceNow))s")
    ////                print("ciImg2: \(ciImg?.properties ?? [:])")
    //
    ////                DispatchQueue.main.async {
    ////                    metadataCallback()
    ////                }
    //            })
    //        }
}

/// Resolve an array of Image
///
/// - Parameters:
///   - images: The array of Image
///   - size: The target size for all images
///   - completion: Called when operations completion
//    public static func resolve(images: [Image], completion: @escaping ([UIImage?]) -> Void) {
//        let dispatchGroup = DispatchGroup()
//        var convertedImages = [Int: UIImage]()
//
//        for (index, image) in images.enumerated() {
//            dispatchGroup.enter()
//
//            image.resolve(completion: { resolvedImage in
//                if let resolvedImage = resolvedImage {
//                    convertedImages[index] = resolvedImage
//                }
//
//                dispatchGroup.leave()
//            })
//        }
//
//        dispatchGroup.notify(queue: .main, execute: {
//            let sortedImages = convertedImages
//                .sorted(by: { $0.key < $1.key })
//                .map({ $0.value })
//            completion(sortedImages)
//        })
//    }

//func loadToView(_ imageView: UIImageView) {
//    guard imageView.frame.size != CGSize.zero else {
//        imageView.image = GalleryBundle.image("gallery_placeholder")
//        return
//    }
//
//    if imageView.tag == 0 {
//        imageView.image = GalleryBundle.image("gallery_placeholder")
//    } else {
//        PHImageManager.default().cancelImageRequest(PHImageRequestID(imageView.tag))
//    }
//
//    let options = PHImageRequestOptions()
//    options.isNetworkAccessAllowed = true
//
//    if let asset = PHAsset.fetchAssets(withLocalIdentifiers: [assetId], options: nil).firstObject {
//        let id = Image.imageManager.requestImage(
//            for: asset,
//            targetSize: imageView.frame.size,
//            contentMode: .aspectFill,
//            options: options) { image, _ in
//            imageView.image = image
//        }
//
//        imageView.tag = Int(id)
//    }
//    //
//    imageView.setNeedsDisplay()
//}
//}
