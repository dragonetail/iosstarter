import UIKit
import Photos
import PureLayout
import CyaneaOctopus
import CyaneaOctopus.Swift


protocol SectionSelectedDelegate: class {
    func didSelectSection(_ headerCell: HeaderCell)
}

class HeaderCell: UICollectionViewCell {
    static var identifier: String {
        return String(describing: HeaderCell.self)
    }
    
    override var isSelected: Bool {
        didSet {
            selectButton.isSelected = isSelected
        }
    }
    
    lazy var label: UILabel = {
        let label = UILabel().autoLayout("albumListView")
        label.font = Config.Font.Main.regular.withSize(14)
        label.textColor = UIColor.black

        return label
    }()


    lazy var selectButton: UIButton = {
        var selectButton: UIButton = UIButton(frame: CGRect(x: 100, y: 400, width: 100, height: 50)).autoLayout("albumListView")
        selectButton.addTarget(self, action: #selector(self.selectButtonTapped), for: .touchUpInside)
        //selectButton.setImage(UIImage(named: "picture_unselect"), for: .normal)
        //Ref: https://briangrinstead.com/blog/ios-uicolor-picker/
        //http://www.flatuicolorpicker.com/blue-rgb-color-code/
        //https://github.com/adammcelhaney/CyaneaOctopus
        selectButton.setTitleColor(UIColor.flatSkyBlueColor(), for: .normal)
        selectButton.titleLabel?.font = UIFont.init(name: "Helvetica", size: 14)
        selectButton.setTitle("选择", for: .normal)
        selectButton.setTitle("取消选择", for: .selected)
        return selectButton
    }()

    @objc func selectButtonTapped() {
        selectButton.isSelected = !selectButton.isSelected
        self.delegate.didSelectSection(self)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        _ = self.autoLayout("HeaderCell")
        
        setupAndComposeView()
        
        // bootstrap Auto Layout
        self.setNeedsUpdateConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupAndComposeView() {
        self.contentView.addSubview(label)
        self.contentView.addSubview(selectButton)
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
        label.autoAlignAxis(toSuperviewAxis: .horizontal)
        label.autoPinEdge(toSuperviewEdge: .left, withInset: 10)
        
        selectButton.autoAlignAxis(toSuperviewAxis: .horizontal)
        selectButton.autoPinEdge(toSuperviewEdge: .right, withInset: 10)
    }
    
    private var delegate: SectionSelectedDelegate!
    func setTitleAndDelegate(_ headerTitle: String, delegate: SectionSelectedDelegate) {
        label.text = headerTitle
        
        self.delegate = delegate
    }
}
