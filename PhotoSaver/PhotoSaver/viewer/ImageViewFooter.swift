import UIKit
import PureLayout
import SwiftBaseBootstrap

protocol ImageViewFooterDelegate: class {
    func deleteDelegate(_ footerView: ImageViewFooter, _ button: UIButton)
    func favoriteDelegate(_ footerView: ImageViewFooter, _ button: UIButton)
    func menueDelegate(_ footerView: ImageViewFooter, _ button: UIButton)
    func infoDelegate(_ footerView: ImageViewFooter, _ button: UIButton)
}

class ImageViewFooter: BaseViewWithAutolayout {
    weak var viewDelegate: ImageViewFooterDelegate?

    lazy var deleteButton: UIButton = {
        let image = UIImage(named: "delete")!
        let button = UIButton(type: .custom).autoLayout("deleteButton")
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(ImageViewFooter.deleteAction(button:)), for: .touchUpInside)

        return button
    }()

    lazy var favoriteButton: UIButton = {
        let image = UIImage(named: "favorite")!
        let button = UIButton(type: .custom).autoLayout("favoriteButton")
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(ImageViewFooter.favoriteAction(button:)), for: .touchUpInside)

        return button
    }()

    lazy var menuButton: UIButton = {
        let image = UIImage(named: "menu")!
        let button = UIButton(type: .custom).autoLayout("menuButton")
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(ImageViewFooter.menuAction(button:)), for: .touchUpInside)

        return button
    }()

    lazy var infoButton: UIButton = {
        let image = UIImage(named: "info")!
        let button = UIButton(type: .custom).autoLayout("infoButton")
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(ImageViewFooter.infoAction(button:)), for: .touchUpInside)

        return button
    }()

    override func setupAndComposeView() {
        _ = self.autoLayout("ImageViewFooter")

        [favoriteButton, infoButton, deleteButton, menuButton].forEach { (view) in
            addSubview(view)
        }
    }

    // invoked only once
    override func setupConstraints() {
        let views: NSArray = [favoriteButton, infoButton, deleteButton, menuButton]
        views.autoSetViewsDimension(.height, toSize: 50)
        views.autoDistributeViews(along: .horizontal, alignedTo: .horizontal, withFixedSpacing: 10.0, insetSpacing: true, matchedSizes: true)
        favoriteButton.autoAlignAxis(toSuperviewAxis: .horizontal)
    }

    @objc func deleteAction(button: UIButton) {
        self.viewDelegate?.deleteDelegate(self, button)
    }

    @objc func menuAction(button: UIButton) {
        self.viewDelegate?.menueDelegate(self, button)
    }

    @objc func favoriteAction(button: UIButton) {
        self.viewDelegate?.favoriteDelegate(self, button)
    }

    @objc func infoAction(button: UIButton) {
        self.viewDelegate?.infoDelegate(self, button)
    }
}
