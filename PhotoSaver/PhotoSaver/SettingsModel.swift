import GRDB

enum SettingsType: Int, Codable {
    case profile
}

// MARK: - 数据库模型，APP应用设置
struct SettingsModel {
    var settingsType: SettingsType
    var contents: String //JSON
}

// MARK: - 数据映射
extension SettingsModel: Codable, FetchableRecord, MutablePersistableRecord {
    private enum CodingKeys: String, CodingKey, ColumnExpression {
        case settingsType = "settingsType"
        case contents = "contents"
    }
}

// MARK: - 数据访问
extension SettingsModel {
    static func getProfile(_ db: Database) throws -> SettingsModel? {
        let profile = try SettingsModel
            .filter(CodingKeys.settingsType == SettingsType.profile.rawValue)
            .fetchOne(db)
        
        return profile
    }
}
