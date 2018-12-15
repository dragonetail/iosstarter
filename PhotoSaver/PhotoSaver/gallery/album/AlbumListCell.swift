import UIKit
import PureLayout

class AlbumListCell: UITableViewCell {

    lazy var albumImageView: UIImageView =  {
        let imageView = UIImageView().autoLayout("albumImageView")
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.image = Image._palceHolder
        
        return imageView
    }()
    lazy var albumTitleLabel: UILabel = {
        let label = UILabel().autoLayout("albumTitleLabel")
        label.numberOfLines = 1
        label.font = Config.Font.Text.regular.withSize(14)
        
        return label
    }()
    lazy var itemCountLabel: UILabel = {
        let label = UILabel().autoLayout("itemCountLabel")
        label.numberOfLines = 1
        label.font = Config.Font.Text.regular.withSize(10)
        
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        //_ = self.configureForAutoLayout("AlbumListCell")
        self.backgroundColor = UIColor.clear
        
        setupAndComposeView()
        
        // bootstrap Auto Layout
        self.setNeedsUpdateConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupAndComposeView() {
        [albumImageView, albumTitleLabel, itemCountLabel].forEach {
            addSubview($0)
        }
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
        albumImageView.autoPinEdge(toSuperviewEdge: .left, withInset: 12.0)
        albumImageView.autoPinEdge(toSuperviewEdge: .top, withInset: 5.0)
        albumImageView.autoPinEdge(toSuperviewEdge: .bottom, withInset: 5.0)
        albumImageView.autoMatch(.width, to: .height, of: albumImageView, withOffset: 0)
        
        albumTitleLabel.autoPinEdge(.left, to: .right, of: albumImageView, withOffset: 10)
        albumTitleLabel.autoPinEdge(toSuperviewEdge: .top, withInset: 24)
        albumTitleLabel.autoPinEdge(toSuperviewEdge: .right, withInset: -10)
        
        itemCountLabel.autoPinEdge(.left, to: .right, of: albumImageView, withOffset: 10)
        itemCountLabel.autoPinEdge(.top, to: .bottom, of: albumTitleLabel, withOffset: 6)
    }
    
    func setAlbum(_ album: Album) {
        albumTitleLabel.text = album.title
        itemCountLabel.text = "\(album.count)"
        
        //TODO from DB, user choosen
        if let image = album.sections.first?.images.first {
            image.loadToImageView(albumImageView)
        }else{
            albumImageView.image = Image._palceHolder
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        //albumImageView.image = Image._palceHolder
    }

}
