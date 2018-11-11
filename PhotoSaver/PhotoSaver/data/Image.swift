import UIKit
import Photos

public enum MediaType: String {
    case image
    case video
}

/// Wrap a PHAsset
public class Image: Equatable {
    public var id: String
    public var assetId: String
    public var isSelected: Bool = false
    public var type: MediaType = .image
    //public let asset: PHAsset
    //public var url: String?

    // MARK: - Initialization

    init(asset: PHAsset) {
        self.id = UUID.init().uuidString
        self.assetId = asset.localIdentifier
    }

//
//
////    init(id: String) {
////        self.id = id
////    }
//
//    public func media(_ completion: @escaping (_ image: UIImage?, _ error: NSError?) -> Void) {
////        if let assetID = self.assetID {
////            if let asset = PHAsset.fetchAssets(withLocalIdentifiers: [assetID], options: nil).firstObject {
//        Image.image(for: asset) { image in
//            completion(image, nil)
//        }
////            }
////        } else {
////            completion(self.placeholder, nil)
////        }
//    }
//
//
//    static func image(for asset: PHAsset, completion: @escaping (_ image: UIImage?) -> Void) {
//        let imageManager = PHImageManager.default()
//        let requestOptions = PHImageRequestOptions()
//        requestOptions.isNetworkAccessAllowed = true
//        requestOptions.isSynchronous = false
//        requestOptions.deliveryMode = .opportunistic
//        requestOptions.resizeMode = .fast
//
//        let bounds = UIScreen.main.bounds.size
//        let targetSize = CGSize(width: bounds.width * 2, height: bounds.height * 2)
//        imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFit, options: requestOptions) { image, _ in
//            // WARNING: This could fail if your phone doesn't have enough storage. Since the photo is probably
//            // stored in iCloud downloading it to your phone will take most of the space left making this feature fail.
//            // guard let image = image else { fatalError("Couldn't get photo data for asset \(asset)") }
//            DispatchQueue.main.async {
//                completion(image)
//            }
//        }
//    }

}

// MARK: - UIImage

extension Image {

    /// Resolve UIImage synchronously
    ///
    /// - Parameter size: The target size
    /// - Returns: The resolved UIImage, otherwise nil
    public func resolve(completion: @escaping (UIImage?) -> Void) {
        let options = PHImageRequestOptions()
        options.isNetworkAccessAllowed = true
        options.deliveryMode = .highQualityFormat

        if let asset = PHAsset.fetchAssets(withLocalIdentifiers: [assetId], options: nil).firstObject {
            let targetSize = CGSize(
                width: asset.pixelWidth,
                height: asset.pixelHeight
            )

            PHImageManager.default().requestImage(
                for: asset,
                targetSize: targetSize,
                contentMode: .default,
                options: options) { (image, _) in
                completion(image)
            }
        }
    }

    /// Resolve an array of Image
    ///
    /// - Parameters:
    ///   - images: The array of Image
    ///   - size: The target size for all images
    ///   - completion: Called when operations completion
    public static func resolve(images: [Image], completion: @escaping ([UIImage?]) -> Void) {
        let dispatchGroup = DispatchGroup()
        var convertedImages = [Int: UIImage]()

        for (index, image) in images.enumerated() {
            dispatchGroup.enter()

            image.resolve(completion: { resolvedImage in
                if let resolvedImage = resolvedImage {
                    convertedImages[index] = resolvedImage
                }

                dispatchGroup.leave()
            })
        }

        dispatchGroup.notify(queue: .main, execute: {
            let sortedImages = convertedImages
                .sorted(by: { $0.key < $1.key })
                .map({ $0.value })
            completion(sortedImages)
        })
    }

    func loadToView(_ imageView: UIImageView) {
        guard imageView.frame.size != CGSize.zero else {
            imageView.image = GalleryBundle.image("gallery_placeholder")
            return
        }

        if imageView.tag == 0 {
            imageView.image = GalleryBundle.image("gallery_placeholder")
        } else {
            PHImageManager.default().cancelImageRequest(PHImageRequestID(imageView.tag))
        }

        let options = PHImageRequestOptions()
        options.isNetworkAccessAllowed = true

        if let asset = PHAsset.fetchAssets(withLocalIdentifiers: [assetId], options: nil).firstObject {
            let id = PHImageManager.default().requestImage(
                for: asset,
                targetSize: imageView.frame.size,
                contentMode: .aspectFill,
                options: options) { image, _ in
                imageView.image = image
            }

            imageView.tag = Int(id)
        }
    }

}

// MARK: - Equatable
public func == (lhs: Image, rhs: Image) -> Bool {
    return lhs.assetId == rhs.assetId
}
