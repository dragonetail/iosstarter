import UIKit
import PureLayout

protocol ImageViewHeaderDelegate: class {
    func headerView(_ headerView: ImageViewHeader, didPressClearButton button: UIButton)
}

class ImageViewHeader: BaseViewWithAutolayout {
    weak var viewDelegate: ImageViewHeaderDelegate?

    lazy var exitButton: UIButton = {
        let image = UIImage(named: "exit")!
        let button = UIButton(type: .custom).autoLayout("exitButton")
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(ImageViewHeader.exitAction(button:)), for: .touchUpInside)

        return button
    }()

    @objc func exitAction(button: UIButton) {
        self.viewDelegate?.headerView(self, didPressClearButton: button)
    }

    override func setupAndComposeView() {
        _ = self.autoLayout("ImageViewHeader")

        self.addSubview(self.exitButton)
    }

    // invoked only once
    override func setupConstraints() {
        exitButton.autoPinEdge(toSuperviewEdge: .top, withInset: 10)
        exitButton.autoPinEdge(toSuperviewEdge: .left, withInset: 0)
        exitButton.autoSetDimensions(to: CGSize(width: 50, height: 50))
    }
}
