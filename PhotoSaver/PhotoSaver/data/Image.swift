import UIKit
import Photos

class Image: Equatable {
    static let imageManager = PHCachingImageManager() //PHImageManager.default()

    var id: String
    var assetId: String
    var mediaType: PHAssetMediaType
    var mediaSubtype: PHAssetMediaSubtype
    var creationDate: Date?
    var modificationDate: Date?
    var isFavorite: Bool

    //From Image Data Properties
    var dataSize: Int?
    var orientation: UIImage.Orientation?
    var filePath: String?

    lazy var metadata: ImageMetadata? = {
        if let imageMetadataModel = albumManager.getImageMetadataModel(self.id) {
            let metadata =  ImageMetadata.decode(imageMetadataModel.metadata)
            //print("lazy metadata: \(metadata?.prettyJSON() ?? "UNKOWN-JSON")")
            return metadata
        }
        return nil
    }()

    init(_ imageModel: ImageModel) {
        self.id = imageModel.id
        self.assetId = imageModel.assetId
        self.mediaType = imageModel.mediaType
        self.mediaSubtype = imageModel.mediaSubtype
        self.creationDate = imageModel.creationDate
        self.modificationDate = imageModel.modificationDate
        self.isFavorite = imageModel.isFavorite

        self.dataSize = imageModel.dataSize
        self.orientation = imageModel.orientation
        self.filePath = imageModel.filePath

        //print("....... \(self.assetId)")
    }

    // MARK: Readonly properties
    var dataSizeStr: String {
        guard let dataSize = self.dataSize else {
            return ""
        }
        return ByteCountFormatter.string(fromByteCount: Int64(dataSize), countStyle: .file)
    }
    var filename: String? {
        guard let filePath = self.filePath else {
            return nil
        }
        let fileUrl = NSURL(fileURLWithPath: filePath)
        return fileUrl.lastPathComponent!
    }
    var fileExtension: String? {
        guard let filePath = self.filePath else {
            return nil
        }
        let fileUrl = NSURL(fileURLWithPath: filePath)
        return fileUrl.pathExtension
    }

    func parseInfo(_ info: [AnyHashable: Any]) {
        let isCompleted = info["PHImageResultIsDegradedKey"] as! Int
        guard isCompleted == 0 else {
            return //options.deliveryMode = .opportunistic
        }

        //self.dataSize = data.count
        let nsdata = info["PHImageFileDataKey"] as! NSData
        self.dataSize = nsdata.length
        //self.dataSizeStr = ByteCountFormatter.string(fromByteCount: Int64(self.dataSize!), countStyle: .file)
        //可以使用nsdata的getBytes方法进行部分数据获取或写入文件等

        let fileUrl = info["PHImageFileURLKey"] as! NSURL
        self.filePath = fileUrl.absoluteString!
        //self.filename = fileUrl.lastPathComponent!

        //info["PHImageFileUTIKey"]
        //info["PHImageResultIsDegradedKey"]
        //info["PHImageFileSandboxExtensionTokenKey"]
        //131a5ee11e4e09053cdf297a4a6a2bcf09a90c2c;00;00000000;00000000;00000000;000000000000001a;com.apple.app-sandbox.read;01;01000004;0000000202441039;01;/users/sunyx/library/developer/coresimulator/devices/ff6c4d4d-551b-4334-929e-a1eed3dc764a/data/media/dcim/100apple/img_0002.jpg
        //info["PHImageResultIsPlaceholderKey"] //0
        //info["PHImageResultWantedImageFormatKey"] //10000
        //info["PHImageResultDeliveredImageFormatKey"] //10000

        self.orientation = info["PHImageFileOrientationKey"] as? UIImage.Orientation

        let isInCloud = info["PHImageResultIsInCloudKey"] as! Int //0
        if isInCloud != 0 {
            fatalError("Image is not downloaded from iCloud.")
        }
    }
}

// MARK: - Equatable
func == (lhs: Image, rhs: Image) -> Bool {
    return lhs.assetId == rhs.assetId
}
