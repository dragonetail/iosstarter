import GRDB

// MARK: - 数据库模型，照片分区（根据照片时间进行分区）
struct SectionModel {
    var albumId: String //UUID //外键，相册
    var title: String //分区
    var imageId: String //UUID //外键，相册
}

// MARK: - 数据映射
extension SectionModel: Codable, FetchableRecord, MutablePersistableRecord {
    private enum CodingKeys: String, CodingKey, ColumnExpression {
        case albumId = "albumId"
        case title = "title"
        case imageId = "imageId"
    }
}

// MARK: - 数据访问
extension SectionModel {
    static let image = belongsTo(ImageModel.self)
    var image: QueryInterfaceRequest<ImageModel> {
        return request(for: SectionModel.image)
    }

    static func filterByAlbumId(_ albumId: String) -> QueryInterfaceRequest<SectionModel> {
        return filter(CodingKeys.albumId == albumId)
    }
}
