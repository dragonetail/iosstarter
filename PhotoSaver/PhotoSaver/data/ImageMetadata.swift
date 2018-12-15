import Foundation
import Photos
import ImageIOSwift_F2
import SwiftyJSON

struct ImageMetadataLocation: Codable {
    var latitude: CLLocationDegrees //Double
    var longitude: CLLocationDegrees
    var altitude: CLLocationDistance //Double, Type used to represent a distance in meters.
    var horizontalAccuracy: CLLocationAccuracy //Double, 位置精度级别
    var verticalAccuracy: CLLocationAccuracy
    var course: CLLocationDirection //Double, 0.0 - 359.9 degrees, 0 being true North
    var speed: CLLocationSpeed //Double, speed of the location in m/s
    var timestamp: Date

    init(_ location: CLLocation) {
        self.latitude = location.coordinate.latitude
        self.longitude = location.coordinate.longitude
        self.altitude = location.altitude
        self.horizontalAccuracy = location.horizontalAccuracy
        self.verticalAccuracy = location.verticalAccuracy
        self.course = location.course
        self.speed = location.speed
        self.timestamp = location.timestamp
    }
}

struct ImageMetadata: Codable { //
    // MARK: Image Source
    var device: String? //TODO 需要细化
    // MARK: PHAsset Info
    var playbackStyle: PHAsset.PlaybackStyle
    var pixelWidth: Int
    var pixelHeight: Int
    var location: ImageMetadataLocation?
    var duration: TimeInterval //Double
    var assetSourceType: PHAssetSourceType //typeUserLibrary, typeCloudShared, typeiTunesSynced

    init(_ asset: PHAsset) {
        self.playbackStyle = asset.playbackStyle
        self.pixelWidth = asset.pixelWidth
        self.pixelHeight = asset.pixelHeight

        if let location = asset.location {
            self.location = ImageMetadataLocation(location)
        }
        self.duration = asset.duration
        self.assetSourceType = asset.sourceType
        self.playbackStyle = asset.playbackStyle
    }

    // MARK: image meta data using ImageSource
    var imageProperties: CodableImageProperties?

    func encode() -> Data? {
        do {
            let jsonEncoder = JSONEncoder()

            let jsonData = try jsonEncoder.encode(self)
            let compressedData: Data! = jsonData.compress(withAlgorithm: .lzfse)
            return compressedData
        } catch {
            log.error("数据Encode压缩失败。")
            return nil
        }
    }

    static func decode(_ compressedData: Data?) -> ImageMetadata? {
        guard let compressedData = compressedData else {
            return nil
        }
        do {
            let jsonDecoder = JSONDecoder()

            let jsonData: Data? = compressedData.decompress(withAlgorithm: .lzfse)
            if let jsonData = jsonData {
                let metadata = try jsonDecoder.decode(ImageMetadata.self, from: jsonData)

                return metadata
            }
        } catch {
            log.error("数据解压Decode失败。")
        }
        return nil
    }

    func prettyJSON() -> String {
        do {
            let jsonEncoder = JSONEncoder()
            jsonEncoder.outputFormatting = .prettyPrinted

            let jsonData = try jsonEncoder.encode(self)
            let jsonString = String(data: jsonData, encoding: .utf8)
            return jsonString ?? "UNKONWN-JSON"
        } catch {
            log.error("数据JSON化失败。")
            return "UNKONWN-JSON"
        }
    }

}

extension PHAsset.PlaybackStyle: Codable { }
extension PHAssetSourceType: Codable { }
