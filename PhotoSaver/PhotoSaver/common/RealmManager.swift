import RealmSwift

/**
 单体实例，管理Realm的唯一配置实例
 */
class RealmManager {
    static let shared = RealmManager()
    let realm: Realm
    
    private init() {
        //let realm = try! Realm(configuration: Realm.Configuration(inMemoryIdentifier: "TemporaryRealm"))
        realm = try! Realm()
    }
}
