import UIKit
import Photos
import PureLayout

class HeaderCell: UICollectionViewCell {

    lazy var label: UILabel = {
        let label = UILabel()
        label.font = Config.Font.Main.regular.withSize(16)
        label.textColor = UIColor.green

        return label
    }()


    lazy var selectButton: UIButton = {
        var selectButton: UIButton = UIButton(frame: CGRect(x: 100, y: 400, width: 100, height: 50))
        selectButton.addTarget(self, action: #selector(self.selectButtonTapped), for: .touchUpInside)
        selectButton.setImage(UIImage(named: "picture_unselect"), for: .normal)
        return selectButton
    }()

    @objc func selectButtonTapped() {
        print("selectButtonTapped")
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
        label.autoAlignAxis(toSuperviewAxis: .baseline)
        label.autoPinEdge(toSuperviewEdge: .left, withInset: 15)

        self.contentView.addSubview(selectButton)
        selectButton.autoAlignAxis(toSuperviewAxis: .baseline)
        selectButton.autoPinEdge(toSuperviewEdge: .right, withInset: 15)
    }

}
