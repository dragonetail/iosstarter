import UIKit
import Photos
import PureLayout

class ImageCell: UICollectionViewCell {
    static var identifier: String {
        return String(describing: ImageCell.self)
    }
    
    override var isHighlighted: Bool {
        didSet {
            highlightOverlay.isHidden = !isHighlighted
        }
    }

    override var isSelected: Bool {
        didSet {
            //TODO image.isSelected 删除
            if isSelected {
                UIView.animate(withDuration: 0.1, animations: {
                    self.frameView.alpha = 1
                })
                isHighlighted = true
            } else {
                frameView.alpha = 0
                isHighlighted = false
            }
        }
    }

     lazy var imageView: UIImageView = {
        let imageView = UIImageView().autoresizingMask("imageView")
        imageView.image = Image._palceHolder
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = false

        return imageView
    }()
     lazy var highlightOverlay: UIView = {
        let view = UIView().autoLayout("highlightOverlay")
        view.isUserInteractionEnabled = false
        view.backgroundColor = FrameView.borderColor.withAlphaComponent(0.1)
        view.isHidden = true

        return view
    }()
     lazy var frameView: FrameView = {
        let frameView = FrameView(frame: .zero).autoLayout("frameView")
        frameView.alpha = 0
        frameView.isUserInteractionEnabled = false

        return frameView
    }()
    
   
    override init(frame: CGRect) {
        super.init(frame: frame)
        _ = self.autoresizingMask("ImageCell")
        
        setupAndComposeView()
        
        // bootstrap Auto Layout
        self.setNeedsUpdateConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    // Should overritted by subclass, setup view and compose subviews
    func setupAndComposeView() {
        self.isUserInteractionEnabled = false
        
        [imageView, frameView, highlightOverlay].forEach {
            self.contentView.addSubview($0)
        }
    }
    
    fileprivate var didSetupConstraints = false
    override func updateConstraints() {
        if (!didSetupConstraints) {
            didSetupConstraints = true
            setupConstraints()
        }
        //modifyConstraints()
        
        super.updateConstraints()
    }
    
    // invoked only once
    func setupConstraints() {
        imageView.autoPinEdgesToSuperviewEdges()
        frameView.autoPinEdgesToSuperviewEdges()
        highlightOverlay.autoPinEdgesToSuperviewEdges()
    }

    
    private var image: Image?
    func setImage(_ image: Image) {
        self.image = image
        
        image.loadToImageView(imageView)
    }
}
