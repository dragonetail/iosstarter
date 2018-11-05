import UIKit
import ATGMediaBrowser

class PhotoGalleryController: UIViewController {
    // 控件
    private lazy var albumListController: AlbumListController = {
        let albumListController = AlbumListController()
//        albumListController.delegate = self
        return albumListController
    }()
    private lazy var photoGalleryView: PhotoGalleryView = {
        let photoGalleryView = PhotoGalleryView()
        return photoGalleryView
    }()
    
    // 初始化逻辑
    override func viewDidLoad() {
        super.viewDidLoad()
        
        eventBus.bindPageShowImages(pageShowImages)
        
        view.backgroundColor = UIColor.white

        view.addSubview(photoGalleryView)
        photoGalleryView.autoPinEdgesToSuperviewSafeArea(with: UIEdgeInsets.zero)

        addChild(albumListController)
        photoGalleryView.insertAlbumListControllerView(albumListController)
        albumListController.didMove(toParent: self)

        loadAlbums()
    }

    private func loadAlbums() {
        let library = ImagesLibrary()
        let runOnce = RunOnce()
        runOnce.run {
            library.reload {
                self.albumListController.albums = library.albums
                self.albumListController.tableView.reloadData()

                if let album = library.albums.first {
                    eventBus.triggerSelectAlbum(album)
                }
                self.photoGalleryView.stopLoadingIndicatorView()
            }
        }
    }
    
     var imageViewController: ImageViewController!
    private var album: Album?
    private var indexPath: IndexPath?
    
    func pageShowImages(album: Album, indexPath: IndexPath){
        self.album = album
        self.indexPath = indexPath
        
        self.imageViewController = ImageViewController(album: album, initialIndexPath: indexPath)
        
        self.present(self.imageViewController!, animated: false, completion: nil)

    }
}
