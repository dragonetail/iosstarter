import UIKit
import PureLayout
import SwiftBaseBootstrap

class NoPhotoAuthorizationController: BaseViewControllerWithAutolayout {
    static let image: UIImage? = GalleryBundle.image("gallery_empty_view_image")
    static let textColor: UIColor = UIColor(red: 102 / 255, green: 118 / 255, blue: 138 / 255, alpha: 1)
    static let regular: UIFont = UIFont.systemFont(ofSize: 1)

    lazy var imageView: UIImageView = {
        let view = UIImageView().autoLayout("imageView")
        view.image = EmptyView.image

        return view
    }()

    lazy var label: UILabel = {
        let label = UILabel().autoLayout("label")
        label.textColor = NoPhotoAuthorizationController.textColor
        label.font = NoPhotoAuthorizationController.regular.withSize(14)
        let labelString = "Gallery.EmptyView.Text"._localize(fallback: "应用APP没有获取访问相册的授权。\n\n点击设定修改应用授权")

        let index = labelString.firstIndex(of: "\n")
        let offset = index!.encodedOffset
        let firstRang = NSMakeRange(0, offset)
        let secondRang = NSMakeRange(offset, labelString.count - offset)

        let labelText = NSMutableAttributedString(string: labelString as String)

        labelText.addAttributes([NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font: NoPhotoAuthorizationController.regular.withSize(14)], range: firstRang)
        labelText.addAttributes([NSAttributedString.Key.foregroundColor: UIColor.flatSkyBlueColor(), NSAttributedString.Key.font: NoPhotoAuthorizationController.regular.withSize(14)], range: secondRang)

        label.attributedText = labelText
        label.textAlignment = .center
        label.numberOfLines = 5

        //用户交互功能打开状态
        label.isUserInteractionEnabled = true
        //点击事件
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(NoPhotoAuthorizationController.labelTapped(sender:)))
        //绑定tap
        label.addGestureRecognizer(tap)

        return label
    }()


    override func setupAndComposeView() {
        self.view.backgroundColor = UIColor.white

        [label, imageView].forEach {
            self.view.addSubview($0)
        }
    }
    override func setupConstraints() {
        imageView.autoCenterInSuperview()
        label.autoPinEdge(.top, to: .bottom, of: imageView, withOffset: 15)
        label.autoAlignAxis(toSuperviewAxis: .vertical)
    }

    @objc private func labelTapped(sender: UIView) {
        //Ref: https://www.jianshu.com/p/580d84dda738
        //Ref: https://gist.github.com/deanlyoung/368e274945a6929e0ea77c4eca345560
        if let url = URL(string: UIApplication.openSettingsURLString) {
            //if let url = URL(string: "App-prefs:root=General&path=ACCESSIBILITY") {
            if (UIApplication.shared.canOpenURL(url)) {
                UIApplication.shared.open(url, options: [:], completionHandler: {
                    (_: Bool) -> Void in
                    //print("completed")
                })
            }
        }
    }

}
