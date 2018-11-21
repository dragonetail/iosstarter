import UIKit
import Photos
import PureLayout

protocol AlbumListControllerDelegate: class {
    func didSelectAlbum(_ controller: AlbumListController, didSelect album: Album)
}

class AlbumListController: UIViewController {

    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        tableView.rowHeight = 84

        tableView.dataSource = self
        tableView.delegate = self

        return tableView
    }()

    lazy var blurView: UIVisualEffectView = {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: .extraLight))

        return view
    }()

    let delegate: AlbumListControllerDelegate?

    init(delegate: AlbumListControllerDelegate?) {
        self.delegate = delegate

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private var expandedTopConstraint: NSLayoutConstraint?
    private var collapsedTopConstraint: NSLayoutConstraint?

    internal func updateToggleConstraint(_ result: (expandedTopConstraint: NSLayoutConstraint, collapsedTopConstraint: NSLayoutConstraint)) {
        self.expandedTopConstraint = result.expandedTopConstraint
        self.collapsedTopConstraint = result.collapsedTopConstraint
    }


    private var animating: Bool = false
    var selectedIndex: Int? = nil
    var albums: [Album] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
    }

    func setup() {
        view.backgroundColor = UIColor.clear
        tableView.backgroundColor = UIColor.clear
        tableView.backgroundView = blurView

        view.addSubview(tableView)
        tableView.register(AlbumListCell.self, forCellReuseIdentifier: String(describing: AlbumListCell.self))

        tableView.autoPinEdgesToSuperviewEdges()

        AlbumManager.shared.albumsLoadingDelegate = self
    }


    private var needToReload: Bool = false
    internal func toggle(_ expanding: Bool) {
        guard !animating else { return }

        animating = true

        if expanding {
            collapsedTopConstraint?.isActive = false
            expandedTopConstraint?.isActive = true
            if needToReload {
                needToReload = false
                self.tableView.reloadData()
            }
        } else {
            expandedTopConstraint?.isActive = false
            collapsedTopConstraint?.isActive = true
        }

        UIView.animate(withDuration: 0.25, delay: 0, options: UIView.AnimationOptions(), animations: {
            self.view.superview?.layoutIfNeeded()
        }, completion: { finished in
            self.animating = false
        })
    }

}

extension AlbumListController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return albums.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: AlbumListCell.self), for: indexPath)
        as! AlbumListCell

        let album = albums[(indexPath as NSIndexPath).row]
        cell.configure(album)
        cell.backgroundColor = UIColor.clear

        return cell
    }
}

extension AlbumListController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        selectedIndex = (indexPath as NSIndexPath).row
        let album = albums[selectedIndex!]
        delegate?.didSelectAlbum(self, didSelect: album)
    }
}

extension AlbumListController: AlbumsLoadingDelegate {
//    func albumsFirstLoaded(_ albumManager: AlbumManager) {
//        let albumManager = AlbumManager.shared
//        self.albums = albumManager.albums
//
//
//
//        self.tableView.reloadData()
//    }
    func albumsLoaded(_ albumManager: AlbumManager) {
        let albumManager = AlbumManager.shared
        self.albums = albumManager.albums

        if selectedIndex == nil, let album = self.albums.first {
            selectedIndex = 0
            self.delegate?.didSelectAlbum(self, didSelect: album)
        }

        if expandedTopConstraint?.isActive ?? false {
            self.tableView.reloadData()
        } else {
            self.needToReload = true
        }
    }
}
