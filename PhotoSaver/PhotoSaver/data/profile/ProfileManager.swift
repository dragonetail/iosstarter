import UIKit
import Photos
import GRDB
import SwiftyJSON

class ProfileManager {
    static let shared = ProfileManager()

    var profile: ProfileData = ProfileData()
    var profileChanged : Bool = false

    private init() {
        FileUtils.createDirectory("images")
    }

    func load() {
        do {
            let startTime = CACurrentMediaTime()
            try dbConn.read { db in
                if let profileModel = try SettingsModel.getProfile(db) {
                    if let profile = ProfileData.parse(profileModel.contents) {
                        self.profile = profile
                        log.debug("加载配置信息成功：\(lround((CACurrentMediaTime() - startTime) * 1000))ms")
                    }
                } else {
                    log.info("数据库中没有配置信息。")
                }
                profileChanged = false
            }
        } catch {
            log.warning("从数据库中加载配置信息失败：\(error)")
        }
    }

    func save() {
        guard  profileChanged else {
            return
        }
        do {
            let startTime = CACurrentMediaTime()
            try dbConn.write { db in
                let profileJson = profile.toJson()
                if let profileModel = try SettingsModel.getProfile(db) {
                    var targetModel = profileModel
                    targetModel.contents = profileJson
                    try targetModel.update(db)
                    log.debug("更新配置信息成功：\(lround((CACurrentMediaTime() - startTime) * 1000))ms \(profileJson)")
                } else {
                    var profileModel = SettingsModel(settingsType: SettingsType.profile, contents: profileJson)
                    try profileModel.save(db)

                    log.debug("保存配置信息成功：\(lround((CACurrentMediaTime() - startTime) * 1000))ms \(profileJson)")
                }
                profileChanged = false
            }
        } catch {
            log.warning("更新数据库中配置信息失败：\(error)")
        }
    }
    
     func markChanged() {
        profileChanged = true
    }
}
