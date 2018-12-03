import UIKit
import ATGMediaBrowser

class PhotoGalleryController: UIViewController {
    // 控件
    private var albumListExpanding: Bool = true
    private lazy var albumListButton: AlbumListButton = {
        let albumListButton = AlbumListButton()
        //albumListButton.updateText("Blank Title")

        albumListButton.addTarget(self, action: #selector(albumListButtonTapped(_:)), for: .touchUpInside)

        return albumListButton
    }()
    private lazy var albumListController: AlbumListController = {
        let albumListController = AlbumListController(delegate: self)
        return albumListController
    }()

    private lazy var photoGalleryView: PhotoGalleryView = {
        let photoGalleryView = PhotoGalleryView()
        photoGalleryView.setup(delegate: self, albumListButton: albumListButton)

        return photoGalleryView
    }()

    // 数据
    private var album: Album? = nil

    // 初始化逻辑
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.white

        //AlbumManager.shared.albumLoadingDelegate = self

        view.addSubview(photoGalleryView)
        photoGalleryView.autoPinEdgesToSuperviewSafeArea()

        //addChild(albumListController)
        albumListController.beginAppearanceTransition(true, animated: false)
        let result = photoGalleryView.insertAlbumListControllerView(albumListController.view)
        albumListController.updateToggleConstraint(result)
        albumListController.endAppearanceTransition()
        albumListController.didMove(toParent: self)
        
        self.view.isMultipleTouchEnabled = true
    }

    @objc func albumListButtonTapped(_ button: AlbumListButton) {
        toggaleAlbumControllerView()
    }

    func toggaleAlbumControllerView() {
        albumListExpanding = !albumListExpanding
        albumListController.toggle(albumListExpanding)
        albumListButton.toggle(albumListExpanding)
    }
}


extension PhotoGalleryController: AlbumListControllerDelegate {
    func didSelectAlbum(_ controller: AlbumListController, didSelect album: Album) {
        self.album = album
        
        albumListButton.updateText(album.title)
        toggaleAlbumControllerView()
        
        let dataSource = AlbumImageDataSource(album)
        self.photoGalleryView.update(dataSource)
        
    }
}

extension PhotoGalleryController: PhotoGalleryViewDelegate {
    func didSelectImage(_ photoGalleryView: PhotoGalleryView, dataSource: PhotoGalleryViewDataSource?, indexPath: IndexPath) {
        guard let dataSource = dataSource as? AlbumImageDataSource else{
            return
        }
        
        let imageViewController = ImageViewController()
        print(indexPath)
        imageViewController.dataSource = dataSource.forkOneCyclic(indexPath)
       
        imageViewController.exitProcesser = { indexPath in
                 print(indexPath)
            photoGalleryView.collectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: true)
        }
        
        self.present(imageViewController, animated: false, completion: nil)
    }
}

