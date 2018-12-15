import UIKit
import PureLayout

class FrameView: BaseViewWithAutolayout {
    static var fillColor: UIColor = UIColor(red: 50 / 255, green: 51 / 255, blue: 59 / 255, alpha: 1)
    static var borderColor: UIColor = UIColor(red: 0, green: 239 / 255, blue: 155 / 255, alpha: 1)

    lazy var label: UILabel = {
        let label = UILabel().autoLayout("label")
        label.font = Config.Font.Main.regular.withSize(40)
        label.textColor = UIColor.white
        label.text = "VIP"

        return label
    }()
    lazy var gradientLayer: CAGradientLayer = {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            FrameView.fillColor.withAlphaComponent(0.25).cgColor,
            FrameView.fillColor.withAlphaComponent(0.4).cgColor
        ]

        return gradientLayer
    }()
    lazy var imageView: UIImageView = {
        let imageView = UIImageView().autoLayout("imageView")
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        let image: UIImage? = UIImage(named: "picture_selected")
        imageView.image = image
        //imageView.tintColor = Config.Grid.ArrowButton.tintColor
        imageView.alpha = 1

        return imageView
    }()

    override func setupAndComposeView() {
        _ = self.autoLayout("FrameView")

        addSubview(label)
        addSubview(imageView)
    }


    // invoked only once
    override func setupConstraints() {
        label.autoCenterInSuperview()

        imageView.autoPinEdge(toSuperviewEdge: .top, withInset: 2)
        imageView.autoPinEdge(toSuperviewEdge: .right, withInset: 2)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        gradientLayer.frame = bounds
    }
}
