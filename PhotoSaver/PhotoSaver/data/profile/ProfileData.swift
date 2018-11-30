import Foundation
import SwiftyJSON

class ProfileData: Codable {
    //个人信息-基本信息
    //头像
    var profilePhoto: String!
    //昵称
    var nickname: String!
    //性别["男", "女"]
    var gender: String = "男"
    
    //个人信息-账号信息
    //手机号码
    var mobile: String!
    //微信绑定(OpenId)
    var weichatId: String!
    //支付宝绑定(OpenId)
    var alipayId: String!

    static func parse(_ json: String) -> ProfileData? {
        do {
            let jsonDecoder = JSONDecoder()
            let profile = try jsonDecoder.decode(ProfileData.self, from: json.data(using: .utf8)!)
            return profile
        } catch {
            log.warning("ProfileData的JSON转化失败。\(error)")
            return nil
        }
    }

    func toJson() -> String {
        do {
            let jsonEncoder = JSONEncoder()
            jsonEncoder.outputFormatting = .prettyPrinted
            let jsonData = try jsonEncoder.encode(self)
            let jsonString = String(data: jsonData, encoding: .utf8)!
            return jsonString
        } catch {
            log.warning("ProfileData的JSON转化失败。\(error)")
            return "unknown"
        }
    }
}
