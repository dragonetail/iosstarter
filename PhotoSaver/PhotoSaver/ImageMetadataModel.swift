import GRDB

// MARK: - 数据库模型，媒体数据，照片或视频的附加属性
struct ImageMetadataModel {
    var id: String //UUID
    
    var metadata: Data? //JSON
}

// MARK: - 数据映射
extension ImageMetadataModel: Codable, FetchableRecord, MutablePersistableRecord {
    private enum CodingKeys: String, CodingKey, ColumnExpression {
        case id = "id"
        case metadata = "metadata"
    }
}

// MARK: - 数据访问
extension ImageMetadataModel {
    //.fetchOne(db, key: 1)
    //    static func getById(_ db: Database, id: String) throws -> ImageModel? {
    //        let imageModel = try ImageModel
    //            .filter(CodingKeys.id == id)
    //            .fetchOne(db)
    //
    //        return imageModel
    //    }
}

