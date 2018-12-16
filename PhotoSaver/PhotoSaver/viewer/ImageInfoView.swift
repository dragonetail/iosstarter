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
        let pagingTabView: PagingTabView = PagingTabView()
        pagingTabView.config = PagingTabViewConfig()
        pagingTabView.delegate = self
        pagingTabView.datasource = self

        return pagingTabView
    }()
    
    lazy var propertyInfoView: PropertyInfoView = {
        return PropertyInfoView()
    }()

    
    override func setupAndComposeView() {
        _ = self.autoLayout("ImageInfoView")
        
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
    }
    
    // invoked only once
    override func setupConstraints() {
        pagingTabView.autoPinEdgesToSuperviewEdges()
    }
    
    var image: Image? {
        didSet {
            pagingTabView.setupAndComposeView()
        }
    }
}


extension ImageInfoView: PagingTabViewDelegate {
    func pagingTabView(pagingTabView: PagingTabView, toIndex: Int) {
        print("Switch to paging tab view: \(toIndex)")
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
            propertyInfoView.image = image
            return propertyInfoView
//        case 1:
//            return (image: nil, title: "信息")
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
