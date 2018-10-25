import UIKit

class ArrowButton: UIButton {

    private lazy var label: UILabel = {
        let label = UILabel()
        label.textColor = Config.Grid.ArrowButton.tintColor
        label.font = Config.Font.Main.regular.withSize(16)
        label.textAlignment = .center

        return label
    }()

    private lazy var arrow: UIImageView = {
        let arrow = UIImageView()
        let image: UIImage? = UIImage(named: "down_arrow")
        //        arrow.image = GalleryBundle.image("gallery_title_arrow")?.withRenderingMode(.alwaysTemplate)
        arrow.image = image
        arrow.tintColor = Config.Grid.ArrowButton.tintColor
        arrow.alpha = 0

        return arrow
    }()

    private let padding: CGFloat = 10
    private let arrowSize: CGFloat = 8

    // MARK: - Initialization

    init() {
        super.init(frame: CGRect.zero)

        [label, arrow].forEach({
            addSubview($0)
        })
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Layout

    override func layoutSubviews() {
        super.layoutSubviews()

        label.center = CGPoint(x: bounds.size.width / 2, y: bounds.size.height / 2)

        arrow.frame.size = CGSize(width: arrowSize, height: arrowSize)
        arrow.center = CGPoint(x: label.frame.maxX + padding, y: bounds.size.height / 2)
    }


    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        label.sizeToFit()

        return CGSize(width: label.frame.size.width + arrowSize * 2 + padding,
                      height: size.height)
    }

    // MARK: - Logic

    func updateText(_ text: String) {
        label.text = text.uppercased()
        arrow.alpha = text.isEmpty ? 0 : 1
        invalidateIntrinsicContentSize()
    }

    func toggle(_ expanding: Bool) {
        let transform = expanding
            ? CGAffineTransform(rotationAngle: CGFloat(Double.pi)) : CGAffineTransform.identity

        UIView.animate(withDuration: 0.25, animations: {
            self.arrow.transform = transform
        })
    }


    // MARK: - Touch

    override var isHighlighted: Bool {
        didSet {
            label.textColor = isHighlighted ? UIColor.lightGray : Config.Grid.ArrowButton.tintColor
            arrow.tintColor = isHighlighted ? UIColor.lightGray : Config.Grid.ArrowButton.tintColor
        }
    }
}
