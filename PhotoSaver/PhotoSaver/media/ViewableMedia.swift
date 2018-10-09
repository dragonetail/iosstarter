import UIKit

public enum ViewableType: String {
    case image
    case video
}

/// 媒体显示数据接口
public protocol ViewableMedia {
    var type: ViewableType { get }
    var assetId: String? { get }
    var url: String? { get }
    var placeholder: UIImage { get }

    func media(_ completion: @escaping (_ image: UIImage?, _ error: NSError?) -> Void)
}
