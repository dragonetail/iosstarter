import UIKit
import PureLayout

class ProfileHeaderView: UIView {
    lazy var backgroundImageView: UIImageView = {
        let backgroundImageView = UIImageView(image: UIImage(named: "profile_back4"))
        backgroundImageView.frame = CGRect(x: 0, y: 0, width: 320, height: 130)
        backgroundImageView.autoresizingMask = .flexibleWidth
        backgroundImageView.contentMode = .center
        backgroundImageView.clipsToBounds = true

        return backgroundImageView
    }()

    lazy var profileImageView: UIImageView = {
        let profileImageView = UIImageView()
        profileImageView.frame = CGRect(x: 15, y: 15, width: 100, height: 100)
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        //profileImageView.layer.borderWidth = 1.0
        //profileImageView.layer.borderColor = UIColor.white.cgColor
        profileImageView.clipsToBounds = true
        FileUtils.loadImage(ProfileManager.shared.profile.profilePhoto) { uiImage in
            profileImageView.image = uiImage
        }
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2

        return profileImageView
    }()

    lazy var profileLabel: UILabel = {
        let profileLabel = UILabel()
        profileLabel.font = Config.Font.Main.regular.withSize(16)
        profileLabel.textColor = UIColor.white
        profileLabel.textAlignment = .left
        profileLabel.text = ProfileManager.shared.profile.nickname

        return profileLabel
    }()

    lazy var memberTypeLabel: UILabel = {
        let memberTypeLabel = UILabel()
        memberTypeLabel.font = Config.Font.Main.regular.withSize(14)
        memberTypeLabel.textColor = UIColor.orange
        memberTypeLabel.textAlignment = .left
        memberTypeLabel.text = "钻石会员"

        return memberTypeLabel
    }()

    lazy var capacityLabel: UILabel = {
        let capacityLabel = UILabel()
        capacityLabel.font = Config.Font.Main.regular.withSize(10)
        capacityLabel.textColor = UIColor.white
        capacityLabel.textAlignment = .right
        capacityLabel.text = "64MB / 100GB"

        return capacityLabel
    }()

    lazy var capacityProgressBar: UIProgressView = {
        let progressView = UIProgressView(progressViewStyle: .bar)
        progressView.trackTintColor = UIColor.lightGray
        progressView.tintColor = UIColor.blue

        progressView.setProgress(0.5, animated: true)

        return progressView
    }()

    lazy var rightIcon: UIImageView = {
        let rightIcon = UIImageView(image: UIImage(named: "forward_bold"))
        rightIcon.autoresizingMask = .flexibleWidth
        rightIcon.contentMode = .scaleToFill
        rightIcon.clipsToBounds = true

        return rightIcon
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.frame = CGRect(x: 0, y: 0, width: 0, height: 130)

        [backgroundImageView, profileImageView, profileLabel, memberTypeLabel, capacityLabel, capacityProgressBar, rightIcon].forEach {
            addSubview($0)
        }

        //注册事件，响应头像更新对应处理
        eventBus.bindProfileChanged {
            FileUtils.loadImage(ProfileManager.shared.profile.profilePhoto) { uiImage in
                self.profileImageView.image = uiImage
            }
            self.profileLabel.text = ProfileManager.shared.profile.nickname
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        backgroundImageView.autoPinEdgesToSuperviewEdges()

        profileImageView.autoPinEdge(toSuperviewEdge: .top, withInset: 15)
        profileImageView.autoPinEdge(toSuperviewEdge: .left, withInset: 15)
        profileImageView.autoSetDimensions(to: CGSize(width: 100, height: 100))

        profileLabel.autoPinEdge(.left, to: .right, of: profileImageView, withOffset: 15)
        profileLabel.autoPinEdge(.top, to: .top, of: profileImageView, withOffset: 40)

        memberTypeLabel.autoPinEdge(.left, to: .left, of: profileLabel, withOffset: 0)
        memberTypeLabel.autoPinEdge(.bottom, to: .bottom, of: profileImageView, withOffset: -18)

        capacityLabel.autoPinEdge(.left, to: .right, of: memberTypeLabel, withOffset: 30)
        capacityLabel.autoPinEdge(.bottom, to: .bottom, of: profileImageView, withOffset: -18)

        capacityProgressBar.autoPinEdge(.left, to: .left, of: profileLabel, withOffset: 0)
        capacityProgressBar.autoPinEdge(.right, to: .right, of: capacityLabel, withOffset: 0)
        capacityProgressBar.autoPinEdge(.bottom, to: .bottom, of: profileImageView, withOffset: -13)

        rightIcon.autoPinEdge(toSuperviewEdge: .right, withInset: 15)
        rightIcon.autoPinEdge(.bottom, to: .bottom, of: capacityLabel, withOffset: 0)
        rightIcon.autoSetDimensions(to: CGSize(width: 20, height: 20))
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
