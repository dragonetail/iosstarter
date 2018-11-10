import UIKit
import PureLayout
import CyaneaOctopus

open class ScrollSlider: UIView {

    private weak var scrollView: UIScrollView!
    private lazy var indicatorContainer: UIView = {
        let indicatorContainer = UIView()
        indicatorContainer.backgroundColor = .white
//        indicatorContainer.layer.borderWidth = 1
//        indicatorContainer.layer.borderColor = UIColor.yellow.cgColor
        indicatorContainer.layer.cornerRadius = 25
        indicatorContainer.clipsToBounds = false

        indicatorContainer.layer.shadowColor = UIColor.black.cgColor
        indicatorContainer.layer.shadowOpacity = 0.3
        indicatorContainer.layer.shadowOffset = CGSize(width: 0, height: 1)
        indicatorContainer.layer.shadowRadius = 1

        return indicatorContainer
    }()

    private lazy var labelContainer: UIView = {
        let labelContainer = UIView()
        labelContainer.backgroundColor = .white
        //labelContainer.layer.borderWidth = 1
        //labelContainer.layer.borderColor = UIColor.black.cgColor
        labelContainer.layer.cornerRadius = 25
        labelContainer.clipsToBounds = false

        labelContainer.layer.shadowColor = UIColor.black.cgColor
        labelContainer.layer.shadowOpacity = 0.3
        labelContainer.layer.shadowOffset = CGSize(width: 0, height: 1)
        labelContainer.layer.shadowRadius = 1

        return labelContainer
    }()
    private lazy var dateLabel: UILabel = {
        let dateLabel = UILabel()
        dateLabel.font = Config.Font.Main.regular.withSize(14)
        //Ref: http://colorizer.org/
        //https://icons8.cn/icon/set/%E7%AE%AD%E5%A4%B4/ios7
        dateLabel.textColor = UIColor.flatSkyBlueColor()
        dateLabel.textAlignment = .left

        dateLabel.text = "Hello, world!"

        return dateLabel
    }()
//    private lazy var weekLabel: UILabel = {
//        let weekLabel = UILabel()
//        weekLabel.font = Config.Font.Main.regular.withSize(11)
//        weekLabel.textColor = UIColor.flatSkyBlueColor()
//        weekLabel.textAlignment = .left
//        weekLabel.sizeToFit()
//
//        weekLabel.text = "Hello, world!"
//
//        return weekLabel
//    }()

    private lazy var upImageView: UIImageView = {
        let upImageView = UIImageView(frame: CGRect.zero)
        upImageView.clipsToBounds = false
        upImageView.contentMode = .scaleAspectFit
        upImageView.image = UIImage(named: "up")

        return upImageView
    }()
    private lazy var downImageView: UIImageView = {
        let downImageView = UIImageView(frame: CGRect.zero)
        downImageView.clipsToBounds = false
        downImageView.contentMode = .scaleAspectFit
        downImageView.image = UIImage(named: "down")

        return downImageView
    }()

    convenience init(_ scrollView: UIScrollView) {
        self.init(frame: .zero)

        self.scrollView = scrollView
        //self.scrollView._roundBorder()
        //self._roundBorder()
        //self._shadow()

        setupView()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    func setupView() {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(draggingIndicator(sender:)))
        addGestureRecognizer(pan);

        addSubview(indicatorContainer)
        addSubview(labelContainer)

        indicatorContainer.addSubview(upImageView)
        indicatorContainer.addSubview(downImageView)

        labelContainer.addSubview(dateLabel)
    }

    open override func layoutSubviews() {
        super.layoutSubviews()

        self.autoPinEdge(.top, to: .top, of: scrollView, withOffset: 0)
        self.autoPinEdge(toSuperviewEdge: .right, withInset: -25)
        self.autoSetDimension(.width, toSize: 220)
        self.autoSetDimension(.height, toSize: 50)

        labelContainer.autoPinEdgesToSuperviewEdges()
        dateLabel.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 60))

        labelContainer.isHidden = true

        indicatorContainer.autoPinEdgesToSuperviewEdges()
        indicatorContainer.autoPinEdge(toSuperviewEdge: .left, withInset: 160) // 60 width

        upImageView.autoSetDimensions(to: CGSize(width: 15, height: 15))
        upImageView.autoPinEdge(toSuperviewEdge: .left, withInset: 15)
        upImageView.autoPinEdge(toSuperviewEdge: .top, withInset: 10)

        downImageView.autoSetDimensions(to: CGSize(width: 15, height: 15))
        downImageView.autoPinEdge(toSuperviewEdge: .left, withInset: 15)
        downImageView.autoPinEdge(toSuperviewEdge: .top, withInset: 25)

        fireTimer()
    }

    private var timer: Timer?
    private func fireTimer() {
        if let timer = timer {
            timer.invalidate()
        }
        timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(timerFired(_:)), userInfo: nil, repeats: false)
    }

    @objc private func timerFired(_ time: Timer) {
        guard isDraggingIndicator == false else {
            return
        }
        self.isHidden = true
    }

    private var isDraggingIndicator: Bool = false
    @objc func draggingIndicator(sender: UIPanGestureRecognizer) {

        if sender.state == .began {
            isDraggingIndicator = true
        }

        if sender.state == .changed {
            let offset = sender.translation(in: self.superview!)
            self.center.y += offset.y
            sender.setTranslation(.zero, in: self.superview!)
            if self.frame.origin.y < scrollView.frame.origin.y {
                self.frame.origin.y = scrollView.frame.origin.y
            }

            let maxOffsetY = scrollView.frame.size.height + scrollView.frame.origin.y - self.frame.height
            if self.frame.origin.y > maxOffsetY {
                self.frame.origin.y = maxOffsetY
            }

            let currentOffsetY = self.frame.origin.y - scrollView.frame.origin.y
            let maxIndicatorOffset = scrollView.frame.size.height - self.frame.height
            let offsetPercentage = currentOffsetY / maxIndicatorOffset
            let maxOffset = scrollView.contentSize.height - scrollView.frame.size.height
            let currentOffset = maxOffset * offsetPercentage

            scrollView.contentOffset.y = currentOffset
        }

        if sender.state == .ended {
            isDraggingIndicator = false
            labelContainer.isHidden = true
            fireTimer()
        }
    }

    func updateScrollLabel(_ label: String) {
        guard isDraggingIndicator == true else {
            return
        }

        labelContainer.isHidden = false
        
        let targetStr = label.replacingOccurrences(of: " ", with: "\n")
        
        let index = targetStr.firstIndex(of: "\n")
        let offset = index!.encodedOffset
        let firstRang = NSMakeRange(0, offset)
        let secondRang = NSMakeRange(offset, targetStr.count - offset)
        
        let labelText = NSMutableAttributedString(string: targetStr as String)
        
        labelText.addAttributes([NSAttributedString.Key.foregroundColor: UIColor.flatSkyBlueColor(), NSAttributedString.Key.font: Config.Font.Main.regular.withSize(16)], range: firstRang)
        labelText.addAttributes([NSAttributedString.Key.foregroundColor: UIColor.flatSkyBlueColor(), NSAttributedString.Key.font: Config.Font.Main.regular.withSize(12)], range: secondRang)
        
        dateLabel.attributedText = labelText
        dateLabel.textAlignment = .left
        dateLabel.numberOfLines = 2
    }
    func dragAndScrollView() {
        guard isDraggingIndicator == false else {
            return
        }
        guard scrollView.superview != nil else {
            return
        }

        let maxOffset = scrollView.contentSize.height - scrollView.frame.size.height
        var currentOffset = scrollView.contentOffset.y
        if currentOffset > maxOffset {
            currentOffset = maxOffset
        }
        if currentOffset < 0 {
            currentOffset = 0
        }

        let offsetPercentage = currentOffset / maxOffset

        let maxIndicatorOffset = scrollView.frame.size.height - self.frame.height
        self.frame.origin.y = scrollView.frame.origin.y + maxIndicatorOffset * offsetPercentage

        self.isHidden = false
        fireTimer()
    }
}
