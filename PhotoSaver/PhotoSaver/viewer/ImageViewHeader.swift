import UIKit
import PureLayout

protocol ImageViewHeaderDelegate: class {
    func headerView(_ headerView: ImageViewHeader, didPressClearButton button: UIButton)
    func headerView(_ headerView: ImageViewHeader, didPressMenuButton button: UIButton)
}

class ImageViewHeader: UIView {
    weak var viewDelegate: ImageViewHeaderDelegate?

    lazy var exitButton: UIButton = {
        let image = UIImage(named: "exit")!
        let button = UIButton(type: .custom)
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(ImageViewHeader.exitAction(button:)), for: .touchUpInside)

        return button
    }()
    
    @objc func exitAction(button: UIButton) {
        self.viewDelegate?.headerView(self, didPressClearButton: button)
    }

    lazy var menuButton: UIButton = {
        let image = UIImage(named: "menu")!
        let button = UIButton(type: .custom)
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(ImageViewHeader.menuAction(button:)), for: .touchUpInside)

        return button
    }()
    
    @objc func menuAction(button: UIButton) {
        self.viewDelegate?.headerView(self, didPressMenuButton: button)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.addSubview(self.exitButton)
        self.addSubview(self.menuButton)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        
        exitButton.autoPinEdge(toSuperviewEdge: .top   , withInset: 10)
        exitButton.autoPinEdge(toSuperviewEdge: .left, withInset: 0)
        exitButton.autoSetDimensions(to: CGSize(width: 50, height: 50 ))
        
        menuButton.autoPinEdge(toSuperviewEdge: .top   , withInset: 10)
        menuButton.autoPinEdge(toSuperviewEdge: .right, withInset: 0)
        menuButton.autoSetDimensions(to: CGSize(width: 50, height: 50 ))
    }
}
