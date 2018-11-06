import UIKit
import Photos
import PureLayout
import CyaneaOctopus
import CyaneaOctopus.Swift

class HeaderCell: UICollectionViewCell {

    lazy var label: UILabel = {
        let label = UILabel()
        label.font = Config.Font.Main.regular.withSize(14)
        label.textColor = UIColor.black

        return label
    }()


    lazy var selectButton: UIButton = {
        var selectButton: UIButton = UIButton(frame: CGRect(x: 100, y: 400, width: 100, height: 50))
        selectButton.addTarget(self, action: #selector(self.selectButtonTapped), for: .touchUpInside)
        //selectButton.setImage(UIImage(named: "picture_unselect"), for: .normal)
        //Ref: https://briangrinstead.com/blog/ios-uicolor-picker/
        //http://www.flatuicolorpicker.com/blue-rgb-color-code/
        //https://github.com/adammcelhaney/CyaneaOctopus
        selectButton.setTitleColor(UIColor.flatSkyBlueColor(), for: .normal)
        selectButton.titleLabel?.font = UIFont.init(name: "Helvetica", size:14)
        selectButton.setTitle("选择", for: .normal)
        selectButton.setTitle("取消选择", for: .selected)
        return selectButton
    }()

    @objc func selectButtonTapped() {
        print("selectButtonTapped")
        selectButton.isSelected = !selectButton.isSelected
        
        
//        guard let image = self.image else {
//            return
//        }
//
//        image.isSelected = !image.isSelected
//        if self.image!.isSelected {
//            selectButton.setImage(UIImage(named: "picture_selected"), for: .normal)
//
//        } else {
//            selectButton.setImage(UIImage(named: "picture_unselect"), for: .normal)
//        }
//        self.reconfigure()

    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    func configure(_ headerTitle: String) {
        label.text = headerTitle
    }

    func setup() {
        self.contentView.addSubview(label)
        label.autoAlignAxis(toSuperviewAxis: .horizontal)
        label.autoPinEdge(toSuperviewEdge: .left, withInset: 10)

        self.contentView.addSubview(selectButton)
        selectButton.autoAlignAxis(toSuperviewAxis: .horizontal)
        selectButton.autoPinEdge(toSuperviewEdge: .right, withInset: 10)
    }

}
