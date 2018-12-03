import UIKit
import Photos
import PureLayout

class ImageCell: UICollectionViewCell {
    static var identifier: String {
        return String(describing: ImageCell.self)
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

    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = false

        return imageView
    }()
    private lazy var highlightOverlay: UIView = {
        let view = UIView()
        view.isUserInteractionEnabled = false
        view.backgroundColor = FrameView.borderColor.withAlphaComponent(0.1)
        view.isHidden = true

        return view
    }()
    private lazy var frameView: FrameView = {
        let frameView = FrameView(frame: .zero)
        frameView.alpha = 0
        frameView.isUserInteractionEnabled = false

        return frameView
    }()

//    private lazy var selectButton: UIButton = {
//        var selectButton: UIButton = UIButton(frame: CGRect(x: 100, y: 400, width: 100, height: 50))
//        //selectButton.addTarget(self, action: #selector(self.selectButtonTapped), for: .touchUpInside)
//        selectButton.isUserInteractionEnabled = false
//        selectButton.setImage(UIImage(named: "picture_unselect"), for: .normal)
//        selectButton.setImage(UIImage(named: "picture_selected"), for: .selected)
//        return selectButton
//    }()

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

    override func layoutSubviews() {
        super.layoutSubviews()

        //reconfigure()
    }

    private var image: Image?
    func configure(_ image: Image) {
        self.image = image

        imageView.layoutIfNeeded()
        image.loadToView(imageView)
    }

//    func reconfigure() {
//        guard let image = self.image else {
//            return
//        }
//
//        //selectButton.isSelected = image.isSelected
//
//        if image.isSelected {
//            UIView.animate(withDuration: 0.1, animations: {
//                self.frameView.alpha = 1
//            })
//            isHighlighted = true
//        } else {
//            frameView.alpha = 0
//            isHighlighted = false
//        }
//    }


    private func setup() {
        [imageView, frameView, highlightOverlay].forEach {
            self.contentView.addSubview($0)
        }

        imageView.autoPinEdgesToSuperviewEdges()
        frameView.autoPinEdgesToSuperviewEdges()
        highlightOverlay.autoPinEdgesToSuperviewEdges()

        //selectButton.autoPinEdge(toSuperviewEdge: .top, withInset: 2)
        //selectButton.autoPinEdge(toSuperviewEdge: .right, withInset: 2)

        self.isUserInteractionEnabled = false
    }

//    func toggleSeleced() {
//        guard let image = self.image else {
//            return
//        }
//
//        image.isSelected = !image.isSelected
//
//        self.reconfigure()
//    }
}
