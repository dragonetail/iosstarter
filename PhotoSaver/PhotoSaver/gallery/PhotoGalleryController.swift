import UIKit
import ATGMediaBrowser
import SwiftBaseBootstrap

class PhotoGalleryController: BaseViewControllerWithAutolayout {

    private lazy var topAlbumListSelectorView: AlbumListSelectorView = {
        let topAlbumListSelectorView = AlbumListSelectorView().autoLayout("topAlbumListSelectorView")

        topAlbumListSelectorView.tappedHandler = {
            self.toggaleAlbumControllerView()
        }
        
        return topAlbumListSelectorView
    }()


    private lazy var albumListView: AlbumListView = {
        let albumListView = AlbumListView().autoLayout("albumListView")
        albumListView.delegate = self
        return albumListView
    }()

    private lazy var photoGalleryView: PhotoGalleryView = {
        let photoGalleryView = PhotoGalleryView().autoLayout("photoGalleryView")
        photoGalleryView.delegate = self

        return photoGalleryView
    }()

    //选择的相册
    var selectedAlbum: Album? = nil

    // 初始化逻辑
    override open var accessibilityIdentifier: String {
        return "PhotoGalleryController"
    }
    override func setupAndComposeView() {
        self.view.backgroundColor = UIColor.white
        self.view.isMultipleTouchEnabled = true

        [topAlbumListSelectorView, photoGalleryView, albumListView].forEach {
            view.addSubview($0)
        }
    }

    private var albumListExpanding: Bool = false
    private var expandedTopConstraint: NSLayoutConstraint?
    private var collapsedTopConstraint: NSLayoutConstraint?
    override func setupConstraints() {
        topAlbumListSelectorView.autoSetDimension(.height, toSize: 40)
        topAlbumListSelectorView.autoPinEdgesToSuperviewSafeArea(with: .zero, excludingEdge: .bottom)

        photoGalleryView.autoPinEdge(.top, to: .bottom, of: topAlbumListSelectorView)
        photoGalleryView.autoPinEdgesToSuperviewSafeArea(with: .zero, excludingEdge: .top)

        albumListView.autoPinEdge(toSuperviewEdge: .left)
        albumListView.autoPinEdge(toSuperviewEdge: .right)
        albumListView.autoPinEdge(toSuperviewSafeArea: .bottom)

        NSLayoutConstraint.autoCreateAndInstallConstraints {
            albumListExpanding = false
            collapsedTopConstraint = albumListView.autoPinEdge(toSuperviewSafeArea: .bottom)
        }
        NSLayoutConstraint.autoCreateConstraintsWithoutInstalling {
            expandedTopConstraint = albumListView.autoPinEdge(.top, to: .bottom, of: topAlbumListSelectorView)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        albumManager.albumsLoadingDelegate = self
        //视图延迟加载时，主动询问数据是否加载完成，更新视图
        albumManager.checkLoadedAndNotify()
    }

    func toggaleAlbumControllerView() {
        albumListExpanding = !albumListExpanding

        topAlbumListSelectorView.toggle(albumListExpanding)

        if albumListExpanding {
            collapsedTopConstraint?.autoRemove()
            expandedTopConstraint?.autoInstall()
        } else {
            collapsedTopConstraint?.autoInstall()
            expandedTopConstraint?.autoRemove()
        }

        UIView.animate(withDuration: 0.15, delay: 0, options: UIView.AnimationOptions(), animations: {
            self.albumListView.layoutIfNeeded()
        })
    }
}


extension PhotoGalleryController: AlbumListViewDelegate {
    func didSelectAlbum(didSelect album: Album) {
        selectedAlbum = album

        topAlbumListSelectorView.updateText(album.title)
        toggaleAlbumControllerView()

        self.photoGalleryView.dataSource = AlbumImageDataSource(album)
    }
}

extension PhotoGalleryController: PhotoGalleryViewDelegate {
    func didSelectImage(_ photoGalleryView: PhotoGalleryView, dataSource: PhotoGalleryViewDataSource?, indexPath: IndexPath) {
        guard let dataSource = dataSource as? AlbumImageDataSource else {
            return
        }

        let imageViewController = ImageViewController()
        imageViewController.dataSource = dataSource.forkOneCyclic(indexPath)
        imageViewController.imageViewerSupportDelegate = photoGalleryView

        imageViewController.exitProcesser = { indexPath in
            photoGalleryView.collectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: true)
        }

        self.present(imageViewController, animated: false, completion: nil)
    }
}


extension PhotoGalleryController: AlbumsLoadingDelegate {
    func albumsLoaded(_ albumManager: AlbumManager) {
        let albums = albumManager.albums

        if selectedAlbum == nil, let first = albums.first {
            selectedAlbum = first
            topAlbumListSelectorView.updateText(selectedAlbum!.title)
            photoGalleryView.dataSource = AlbumImageDataSource(selectedAlbum!)
        }

        albumListView.albums = albums

        self.view.setNeedsLayout()
    }
}

