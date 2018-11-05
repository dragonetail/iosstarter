import UIKit
import PureLayout

class EmptyView: UIView {
    static let image: UIImage? = GalleryBundle.image("gallery_empty_view_image")
    static let textColor: UIColor = UIColor(red: 102/255, green: 118/255, blue: 138/255, alpha: 1)
     static let regular: UIFont = UIFont.systemFont(ofSize: 1)
    
    lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.image = EmptyView.image
        
        return view
    }()
    lazy var label: UILabel = {
        let label = UILabel()
        label.textColor = EmptyView.textColor
        label.font = EmptyView.regular.withSize(14)
        label.text = "Gallery.EmptyView.Text".g_localize(fallback: "Nothing to show")
        
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        [label, imageView].forEach {
            addSubview($0)
        }
        
        imageView.autoCenterInSuperview()
        label.autoPinEdge(.top, to: .bottom, of: imageView, withOffset: 12)
//        label.autoAlignAxis(toSuperviewAxis: .horizontal)
        
    }
}
