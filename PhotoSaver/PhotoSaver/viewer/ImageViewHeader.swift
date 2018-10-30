import UIKit

protocol ImageViewHeaderDelegate: class {
    func headerView(_ headerView: ImageViewHeader, didPressClearButton button: UIButton)
    func headerView(_ headerView: ImageViewHeader, didPressMenuButton button: UIButton)
}

class ImageViewHeader: UIView {
    weak var viewDelegate: ImageViewHeaderDelegate?
    static let ButtonSize = CGFloat(50.0)
    static let TopMargin = CGFloat(15.0)

    lazy var clearButton: UIButton = {
        let image = UIImage(named: "clear")!
        let button = UIButton(type: .custom)
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(ImageViewHeader.clearAction(button:)), for: .touchUpInside)

        return button
    }()

    lazy var menuButton: UIButton = {
        let image = UIImage(named: "menu")!
        let button = UIButton(type: .custom)
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(ImageViewHeader.menuAction(button:)), for: .touchUpInside)

        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.addSubview(self.clearButton)
        self.addSubview(self.menuButton)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.clearButton.frame = CGRect(x: 0, y: ImageViewHeader.TopMargin, width: ImageViewHeader.ButtonSize, height: ImageViewHeader.ButtonSize)

        let x = UIScreen.main.bounds.size.width - ImageViewHeader.ButtonSize
        self.menuButton.frame = CGRect(x: x, y: ImageViewHeader.TopMargin, width: ImageViewHeader.ButtonSize, height: ImageViewHeader.ButtonSize)
    }

    @objc func clearAction(button: UIButton) {
        self.viewDelegate?.headerView(self, didPressClearButton: button)
    }

    @objc func menuAction(button: UIButton) {
        self.viewDelegate?.headerView(self, didPressMenuButton: button)
    }
}
