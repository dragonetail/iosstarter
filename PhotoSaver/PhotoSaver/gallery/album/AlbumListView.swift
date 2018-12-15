import UIKit
import Photos
import PureLayout

protocol AlbumListViewDelegate: class {
    func didSelectAlbum(didSelect album: Album)
}

class AlbumListView: BaseViewWithAutolayout {

    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.tableFooterView = UIView().autoLayout("tableView")
        tableView.separatorStyle = .none
        tableView.rowHeight = 84

        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.register(AlbumListCell.self, forCellReuseIdentifier: String(describing: AlbumListCell.self))
        
        tableView.backgroundColor = UIColor.clear
        tableView.backgroundView = blurView

        return tableView
    }()

    lazy var blurView: UIVisualEffectView = {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: .extraLight))
        return view
    }()

    var delegate: AlbumListViewDelegate?

    var albums: [Album] = [] {
        didSet {
            self.tableView.reloadData()
        }
    }

    override func setupAndComposeView() {
        _ = self.autoLayout("albumListView")

        self.backgroundColor = UIColor.clear

        self.addSubview(tableView)
    }

    override func setupConstraints() {
        tableView.autoPinEdgesToSuperviewEdges()
    }
}

extension AlbumListView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return albums.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: AlbumListCell.self), for: indexPath)
        as! AlbumListCell

        let album = albums[(indexPath as NSIndexPath).row]
        cell.layoutIfNeeded()
        cell.setAlbum(album)

        return cell
    }
}

extension AlbumListView: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let selectedAlbum = albums[indexPath.row]
        delegate?.didSelectAlbum(didSelect: selectedAlbum)
    }
}

