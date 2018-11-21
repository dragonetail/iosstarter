import GRDB

enum MediaType: Int, Codable {
    case image
    case video
}
//extension MediaType : DatabaseValueConvertible { }

// MARK: - 数据库模型，媒体数据，照片或视频
struct ImageModel {
    var id: String //UUID
    var assetId: String
    var mediaType: MediaType
}

// MARK: - 数据映射
extension ImageModel: Codable, FetchableRecord, MutablePersistableRecord {
    private enum CodingKeys: String, CodingKey, ColumnExpression {
        case id = "id"
        case assetId = "assetId"
        case mediaType = "mediaType"
    }
}

// MARK: - 数据访问
extension ImageModel {
}
