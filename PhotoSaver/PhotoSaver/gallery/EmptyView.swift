import UIKit
import PureLayout
import SwiftBaseBootstrap

class EmptyView: BaseViewWithAutolayout {
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
        label.textColor = EmptyView.textColor
        label.font = EmptyView.regular.withSize(14)
        label.text = "Gallery.EmptyView.Text".extLocalize(fallback: "Nothing to show")

        return label
    }()

    override func setupAndComposeView() {
        _ = self.autoLayout("EmptyView")

        [label, imageView].forEach {
            addSubview($0)
        }
    }

    // invoked only once
    override func setupConstraints() {
        imageView.autoCenterInSuperview()
        label.autoPinEdge(.top, to: .bottom, of: imageView, withOffset: 12)
        label.autoAlignAxis(toSuperviewAxis: .vertical)
    }

}
