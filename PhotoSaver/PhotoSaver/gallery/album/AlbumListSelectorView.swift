import UIKit
import SwiftBaseBootstrap
import SwiftBaseBootstrap

class AlbumListSelectorView: BaseViewWithAutolayout {
    private static let tintColor: UIColor = UIColor(red: 110 / 255, green: 117 / 255, blue: 131 / 255, alpha: 1)

    lazy var label: UILabel = {
        let label = UILabel().autoLayout("label")
        label.textColor = AlbumListSelectorView.tintColor
        label.font = Config.Font.Main.regular.withSize(16)
        label.textAlignment = .center

        return label
    }()

    lazy var arrow: UIImageView = {
        let arrow = UIImageView().autoLayout("arrow")
        arrow.image = UIImage(named: "down_arrow")
        arrow.tintColor = AlbumListSelectorView.tintColor
        arrow.alpha = 0

        return arrow
    }()

    lazy var container: UIView = {
        let container = BaseViewWithAutolayout().autoLayout("container")
        container.autoRoundBorder(AlbumListSelectorView.tintColor)

        let containerTapGest = UITapGestureRecognizer(target: self, action: #selector(handleTapContainer(recognizer:)))
        containerTapGest.numberOfTapsRequired = 1
        container.addGestureRecognizer(containerTapGest)

        [label, arrow].forEach({
            container.addSubview($0)
        })
        return container
    }()

    override func setupAndComposeView() {
        self.backgroundColor = UIColor.white

        [container].forEach({
            addSubview($0)
        })
    }

    override func setupConstraints() {
        label.sizeToFit()
        container.autoCenterInSuperview()
        container.autoSetDimension(.width, toSize: label.frame.size.width + 8 + 10 * 3)
        container.autoSetDimension(.height, toSize: label.frame.size.height + 10)

        label.autoPinEdge(toSuperviewEdge: .left, withInset: 10)
        label.autoAlignAxis(toSuperviewAxis: .horizontal)

        arrow.autoPinEdge(.left, to: .right, of: label, withOffset: 10)
        arrow.autoSetDimensions(to: CGSize(width: 8, height: 8))
        arrow.autoAlignAxis(toSuperviewAxis: .horizontal)
    }

    func updateText(_ text: String) {
        label.text = text.uppercased()
        arrow.alpha = text.isEmpty ? 0 : 1
        //invalidateIntrinsicContentSize()
    }

    var tappedHandler: (() -> Void)?
    @objc func handleTapContainer(recognizer: UITapGestureRecognizer) {
        tappedHandler?()
    }

    func toggle(_ expanding: Bool) {
        let transform = expanding
            ? CGAffineTransform(rotationAngle: CGFloat(Double.pi)) : CGAffineTransform.identity

        UIView.animate(withDuration: 0.25, animations: {
            self.arrow.transform = transform
        })
    }
}
