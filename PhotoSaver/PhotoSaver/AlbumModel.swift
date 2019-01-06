import GRDB
import Photos

// MARK: - 数据库模型，相册
extension PHAssetCollectionType: Codable { }
extension PHAssetCollectionSubtype: Codable { }
struct AlbumModel {
    var id: String //UUID
    var collectionId: String
    var collectionType: PHAssetCollectionType
    var collectionSubtype: PHAssetCollectionSubtype
    var title: String
}

// MARK: - 数据映射
extension AlbumModel: Codable, FetchableRecord, MutablePersistableRecord {
    // Ref https://developer.apple.com/documentation/foundation/archives_and_serialization/encoding_and_decoding_custom_types
    private enum CodingKeys: String, CodingKey, ColumnExpression {
        case id = "id"
        case collectionId = "collectionId"
        case collectionType = "collectionType"
        case collectionSubtype = "collectionSubtype"
        case title = "title"
    }
}

// MARK: - 数据访问
extension AlbumModel {
    static let sections = hasMany(SectionModel.self)
    var sections: QueryInterfaceRequest<SectionModel> {
        return request(for: AlbumModel.sections)
    }

    static func getSmartAlbumUserLibrary(_ db: Database) throws -> AlbumModel? {
        let smartAlbumUserLibrary = try AlbumModel
            .filter(CodingKeys.collectionType == PHAssetCollectionType.smartAlbum.rawValue && CodingKeys.collectionSubtype == PHAssetCollectionSubtype.smartAlbumUserLibrary.rawValue)
            .fetchOne(db)

        return smartAlbumUserLibrary
    }

//    static func hasImages(_ db: Database, smartAlbumUserLibrary: AlbumModel?) throws -> Bool {
//        if let smartAlbumUserLibrary = smartAlbumUserLibrary {
//            let imageCount: Int = try smartAlbumUserLibrary.sections.fetchCount(db)
//            return (imageCount > 0)
//        }
//        return false
//    }
    
    static func getBy(_ db: Database, collectionId: String) throws -> AlbumModel? {
        let albumModel = try AlbumModel
            .filter(CodingKeys.collectionId == collectionId)
            .fetchOne(db)
        
        return albumModel
    }
}
