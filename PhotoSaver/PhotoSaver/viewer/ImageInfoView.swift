import UIKit
import PureLayout
import Photos
import SwiftPagingTabView

protocol ImageInfoViewDelegate: class {
    func imageInfoView(_ imageInfoView: ImageInfoView, didPressClearButton button: UIButton)
    func imageInfoView(_ imageInfoView: ImageInfoView, didPressMenuButton button: UIButton)
}

class ImageInfoView: UIView {
    weak var viewDelegate: ImageInfoViewDelegate?

//    lazy var label: UILabel = {
//        let label = UILabel()
//        label.font = Config.Font.Main.regular.withSize(14)
//        label.textColor = UIColor.black
//
//        return label
//    }()
    public lazy var pagingTabView: PagingTabView = {
        let pagingTabView: PagingTabView = PagingTabView()
        pagingTabView.config = PagingTabViewConfig()
        pagingTabView.delegate = self
        pagingTabView.datasource = self

        return pagingTabView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        func _shadow() {
            layer.shadowColor = UIColor.black.cgColor
            layer.shadowOpacity = 0.5
            layer.shadowOffset = CGSize(width: 0, height: 2)
            layer.shadowRadius = 2
        }

        func _roundBorder() {
            layer.borderWidth = 1
            layer.borderColor = UIColor.gray.cgColor
            layer.cornerRadius = 5
            clipsToBounds = true
        }
        _shadow()
        _roundBorder()

        self.backgroundColor = UIColor.white

        [pagingTabView].forEach { (view) in
            addSubview(view)
        }

        pagingTabView.reloadAndSetup()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        pagingTabView.autoPinEdgesToSuperviewEdges()
    }

    func update(_ image: Image) {
        let assetId = image.assetId

        guard let asset = PHAsset.fetchAssets(withLocalIdentifiers: [assetId], options: nil).firstObject else {
            //TODO
            return
        }

//
//        PHImageManager.default().requestImageData(for: asset, options: nil, resultHandler:
//            { (data, dataUTI, orientation, info) in
//                print(data)
//                print(dataUTI)
//                print(orientation.rawValue)
//                print(info!)
//
//                let file = info?["PHImageFileURLKey"] as? URL
//                //file?.deletingLastPathComponent()
//                self.label.text = file?.absoluteString
//                print(file?.absoluteString)
//                print(file?.relativePath)
//                print(file?.relativeString)
//
//                let ciImg = CIImage(contentsOf: file!)
//                print("\(ciImg?.properties)")
//
//        })



    }

}


extension ImageInfoView: PagingTabViewDelegate {
    func pagingTabView(pagingTabView: PagingTabView, toIndex: Int) {
        print("Switch to paging tab view: \(toIndex)")
    }

    func reconfigure(pagingTabView: PagingTabView) {
        pagingTabView.tabButtons.forEach { (tabButton) in
            tabButton.configure(config: TabButtonConfig())
        }
    }
}
extension ImageInfoView: PagingTabViewDataSource {
    func segments(pagingTabView: PagingTabView) -> Int {
        return 4
    }

    func tabTitle(pagingTabView: PagingTabView, index: Int) -> (image: UIImage?, title: String?) {
        switch index {
        case 0:
            return (image: nil, title: "概要")
        case 1:
            return (image: nil, title: "通用")
        case 2:
            return (image: nil, title: "TIFF")
        case 3:
            return (image: nil, title: "EXIF")
        default:
            return (image: nil, title: "UNKNOWN")
        }
    }

    func tabView(pagingTabView: PagingTabView, index: Int) -> UIView {
        let view = UILabel()
        view.backgroundColor = UIColor.white
        view.text = "View " + String(index)
        view.textAlignment = .center
        return view
    }
}
