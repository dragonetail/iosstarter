import UIKit
import PureLayout

class ProfileFooterView: UIView {
    lazy var label: UILabel = {
        let label = UILabel()
        label.font = Config.Font.Main.regular.withSize(12)
        label.textColor = UIColor.lightGray
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = "1.0.10-fe86cb2\n官方网址: www.photosaver.com\n微信公众号: 照片保管箱\nQQ反馈群: 18899888\n时光流过的那些光束，是你我最美的回忆"
        
        let paragraphStye = NSMutableParagraphStyle()
        //调整行间距
        paragraphStye.lineSpacing = 5.0
        paragraphStye.alignment =  .center
        paragraphStye.lineBreakMode = NSLineBreakMode.byWordWrapping
        let attributedString = NSMutableAttributedString.init(string: label.text!, attributes: [NSAttributedString.Key.paragraphStyle:paragraphStye])
        label.attributedText = attributedString
        
        return label
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.frame = CGRect(x: 0, y: 0, width: 0, height: 120)
        
        [label].forEach {
            addSubview($0)
        }
        
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        label.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10.0))
        label.sizeToFit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
