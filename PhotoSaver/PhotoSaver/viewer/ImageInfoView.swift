import UIKit
import PureLayout
import Photos
import SwiftBaseBootstrap
import SwiftPagingTabView

protocol ImageInfoViewDelegate: class {
    func imageInfoView(_ imageInfoView: ImageInfoView, didPressClearButton button: UIButton)
    func imageInfoView(_ imageInfoView: ImageInfoView, didPressMenuButton button: UIButton)
}

class ImageInfoView: BaseViewWithAutolayout {
    weak var viewDelegate: ImageInfoViewDelegate?

    public lazy var pagingTabView: PagingTabView = {
        let pagingTabView: PagingTabView = PagingTabView().autoLayout("pagingTabView")
        pagingTabView.config = PagingTabViewConfig()
        pagingTabView.delegate = self
        pagingTabView.datasource = self

        return pagingTabView
    }()

    lazy var propertyInfoView: PropertyInfoView = {
        return PropertyInfoView()
    }()
    lazy var summaryInfoView: SummaryInfoView = {
        return SummaryInfoView()
    }()

    open override func layoutSubviews() {
        super.layoutSubviews()
    }

    override func setupAndComposeView() {
        _ = self.autoLayout("ImageInfoView")

        self.extRoundBorder(UIColor.gray, cornerRadius: 5)
        self.extShadow(shadowOffset: CGSize(width: 0, height: 2), shadowRadius: 2)

        self.backgroundColor = UIColor.white

        [pagingTabView].forEach { (view) in
            addSubview(view)
        }
    }

    // invoked only once
    override func setupConstraints() {
        pagingTabView.autoPinEdgesToSuperviewEdges()
    }

    var image: Image? {
        didSet {
            if oldValue == nil { //因为目前设计信息窗口的数据源为静态的，所以只要第一次初始化创办，这样各个Tab对应的View可以是静态的
                pagingTabView.setupAndComposeView()
            }else{
                pagingTabView.updateTabView()
            }
        }
    }
}


extension ImageInfoView: PagingTabViewDelegate {
    func willShowTabView(pagingTabView: PagingTabView, toIndex: Int, subTabView: UIView) {
        switch toIndex {
        case 0: //概要
            (subTabView as? SummaryInfoView)?.image = image
        case 1: //信息
            (subTabView as? PropertyInfoView)?.image = image
            //        case 2:
            //            return (image: nil, title: "相册")
            //        case 3:
            //            return (image: nil, title: "来源")
        default:
            return
        }
    }

    func reconfigure(pagingTabView: PagingTabView) {
        pagingTabView.tabButtons.forEach { (tabButton) in
            tabButton.config = TabButtonConfig()
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
            return (image: nil, title: "信息")
        case 2:
            return (image: nil, title: "相册")
        case 3:
            return (image: nil, title: "来源")
        default:
            return (image: nil, title: "UNKNOWN")
        }
    }

    func tabView(pagingTabView: PagingTabView, index: Int) -> UIView {
        switch index {
        case 0: //概要
            summaryInfoView.image = image
            return summaryInfoView
        case 1: //信息
            propertyInfoView.image = image
            return propertyInfoView
//        case 2:
//            return (image: nil, title: "相册")
//        case 3:
//            return (image: nil, title: "来源")
        default:
            let view = UILabel()
            view.backgroundColor = UIColor.white
            view.text = "View " + String(index)
            view.textAlignment = .center
            return view
        }
    }
}
