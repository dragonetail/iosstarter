import UIKit
import Photos
import PureLayout

class ImageCell: UICollectionViewCell {

    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill

        return imageView
    }()
    lazy var highlightOverlay: UIView = {
        let view = UIView()
        view.isUserInteractionEnabled = false
        view.backgroundColor = FrameView.borderColor.withAlphaComponent(0.1)
        view.isHidden = true

        return view
    }()
    lazy var frameView: FrameView = {
        let frameView = FrameView(frame: .zero)
        frameView.alpha = 0

        return frameView
    }()

    lazy var selectButton: UIButton = {
        var selectButton: UIButton = UIButton(frame: CGRect(x: 100, y: 400, width: 100, height: 50))
        selectButton.addTarget(self, action: #selector(self.selectButtonTapped), for: .touchUpInside)
        selectButton.setImage(UIImage(named: "picture_unselect"), for: .normal)
        return selectButton
    }()

    @objc func selectButtonTapped() {
        guard let image = self.image else {
            return
        }

        image.isSelected = !image.isSelected
        if self.image!.isSelected {
            selectButton.setImage(UIImage(named: "picture_selected"), for: .normal)

        } else {
            selectButton.setImage(UIImage(named: "picture_unselect"), for: .normal)
        }
        self.reconfigure()
        
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var isHighlighted: Bool {
        didSet {
            highlightOverlay.isHidden = !isHighlighted
        }
    }

    func configure(_ asset: PHAsset) {
        imageView.layoutIfNeeded()
        imageView.g_loadImage(asset)
    }

    private var image: Image?
    func configure(_ image: Image) {
        self.image = image
        configure(image.asset)
        
        reconfigure()
    }
    
    func reconfigure() {
        guard let image = self.image else {
            return
        }
        
        if image.isSelected {
            UIView.animate(withDuration: 0.1, animations: {
                self.frameView.alpha = 1
            })
            isHighlighted = true
        } else {
            frameView.alpha = 0
            isHighlighted = false
        }
    }
    

    func setup() {
        [imageView, frameView, highlightOverlay, selectButton].forEach {
            self.contentView.addSubview($0)
        }

        imageView.autoPinEdgesToSuperviewEdges()
        frameView.autoPinEdgesToSuperviewEdges()
        highlightOverlay.autoPinEdgesToSuperviewEdges()

        selectButton.autoPinEdge(toSuperviewEdge: .top, withInset: 2)
        selectButton.autoPinEdge(toSuperviewEdge: .right, withInset: 2)
    }

}
