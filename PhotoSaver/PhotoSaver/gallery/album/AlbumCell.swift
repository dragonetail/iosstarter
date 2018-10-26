import UIKit
import PureLayout

class AlbumCell: UITableViewCell {

    lazy var albumImageView: UIImageView = self.makeAlbumImageView()
    lazy var albumTitleLabel: UILabel = self.makeAlbumTitleLabel()
    lazy var itemCountLabel: UILabel = self.makeItemCountLabel()

    // MARK: - Initialization

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Config

    func configure(_ album: Album) {
        albumTitleLabel.text = album.collection.localizedTitle
        itemCountLabel.text = "\(album.count)"

        if let item = album.sections.first?.images.first {
            albumImageView.layoutIfNeeded()
            albumImageView.g_loadImage(item.asset)
        }
    }

    // MARK: - Setup

    func setup() {
        [albumImageView, albumTitleLabel, itemCountLabel].forEach {
            addSubview($0)
        }

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

    // MARK: - Controls

    private func makeAlbumImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.image = GalleryBundle.image("gallery_placeholder")

        return imageView
    }

    private func makeAlbumTitleLabel() -> UILabel {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = Config.Font.Text.regular.withSize(14)

        return label
    }

    private func makeItemCountLabel() -> UILabel {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = Config.Font.Text.regular.withSize(10)

        return label
    }
}
