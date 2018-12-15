import GRDB
import Photos

// MARK: - 数据库模型，媒体数据，照片或视频
struct ImageModel {
    var id: String //UUID
    var assetId: String
    var mediaType: PHAssetMediaType
    var mediaSubtype: PHAssetMediaSubtype
    var creationDate: Date?
    var modificationDate: Date?
    var isFavorite: Bool
    
    var dataSize: Int?
    var orientation: UIImage.Orientation?
    var filePath: String?
}

// MARK: - 数据映射
extension ImageModel: Codable, FetchableRecord, MutablePersistableRecord {
    private enum CodingKeys: String, CodingKey, ColumnExpression {
        case id = "id"
        case assetId = "assetId"
        case mediaType = "mediaType"
        case mediaSubtype = "mediaSubtype"
        case creationDate = "creationDate"
        case modificationDate = "modificationDate"
        case isFavorite = "isFavorite"
        case dataSize = "dataSize"
        case orientation = "orientation"
        case filePath = "filePath"
    }
}

// MARK: - 数据访问
extension ImageModel {
    //.fetchOne(db, key: 1) 
//    static func getById(_ db: Database, id: String) throws -> ImageModel? {
//        let imageModel = try ImageModel
//            .filter(CodingKeys.id == id)
//            .fetchOne(db)
//        
//        return imageModel
//    }
}


extension PHAssetMediaType: Codable { }
extension PHAssetMediaSubtype: Codable { }
extension UIImage.Orientation: Codable { }

