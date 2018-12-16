import UIKit
import PureLayout
import Eureka
import SwiftBaseBootstrap

class PropertyInfoView: BaseViewWithAutolayout {
    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView().autoLayout("scrollView")
        
        //scrollView.alwaysBounceVertical = true
        
        scrollView.addSubview(infoStackView)
        self.addSubview(scrollView)
        return scrollView
    }()
    var infoStackView: UIStackView = {
        let  infoStackView = UIStackView().autoLayout("infoStackView")
        
        infoStackView.axis = .vertical
        infoStackView.alignment = .center
        infoStackView.distribution = .fill
        infoStackView.spacing = 5
        
        return infoStackView
    }()

    var image: Image? {
        didSet{
            setupAndComposeView()
        }
    }
    
    override func setupAndComposeView() {
        _ = self.autoLayout("PropertyInfoView")
        self.backgroundColor = UIColor.black
        
        infoStackView.arrangedSubviews.forEach { (view) in
            infoStackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        
        guard let image = image else {
            addAlterInfo()
            return
        }
        
        addInfo("ID", image.id)
        addInfo("assetId", image.assetId)
        addInfo("mediaType", String(describing: image.mediaType))
        addInfo("mediaSubtype", String(describing: image.mediaSubtype))
        addInfo("creationDate", String(describing: image.creationDate))
        addInfo("modificationDate", String(describing: image.modificationDate))
        addInfo("isFavorite", String(describing: image.isFavorite))
        addInfo("dataSize", String(describing: image.dataSize))
        addInfo("dataSizeStr", String(describing: image.dataSizeStr))
        addInfo("orientation", String(describing: image.orientation))
        addInfo("filePath", String(describing: image.filePath))
        addInfo("filename", String(describing: image.filename))
    }
    
    // invoked only once
    override func setupConstraints() {
        scrollView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 0, left: 3, bottom: 0, right: 3))
        
        infoStackView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0))
    }
    
    
    override func layoutSubviews() {
//        infoStackView.subviews.forEach { (lineView) in
//            lineView.autoMatch(.width, to: .width, of: infoStackView)
//            let views = lineView.subviews
//            views[0].autoSetDimension(.width, toSize: 120)
//            views[1].autoSetDimension(.width, toSize: scrollView.bounds.width - 120 - 15)
//        }
        
        super.layoutSubviews()
    }

    func addInfo(_ title: String, _ value: String) {
        let titleLabel = UILabel()
        titleLabel.text = "\(title):"
        titleLabel.textAlignment = .right
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        titleLabel.textColor = UIColor.white
        //titleLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 150).isActive = true
        //titleLabel.setContentHuggingPriority(UILayoutPriority(300), for: .horizontal)

        let valueLabel = UILabel()
        valueLabel.text = "\(value):"
        valueLabel.textColor = UIColor.white
        valueLabel.textAlignment = .left
        valueLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 16, weight: .regular)
        valueLabel.numberOfLines = 0
        valueLabel.lineBreakMode = NSLineBreakMode.byCharWrapping

        let lineView = UIStackView(arrangedSubviews: [
            titleLabel,
            valueLabel,
        ])
        lineView.axis = .horizontal
        lineView.spacing = 10
        lineView.alignment = .center
        lineView.distribution = .fill
        infoStackView.addArrangedSubview(lineView)
    }

    func addAlterInfo() {
        let titleLabel = UILabel()
        titleLabel.text = "no...image...."
        titleLabel.textAlignment = .right
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        titleLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 150).isActive = true
        titleLabel.setContentHuggingPriority(UILayoutPriority(300), for: .horizontal)

        infoStackView.addArrangedSubview(titleLabel)
    }
}
