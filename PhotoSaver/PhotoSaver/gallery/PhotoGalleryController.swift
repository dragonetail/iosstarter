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
    
    func pageShowImages(album: Album, indexPath: IndexPath){
        let pageViewController = PageViewController(album: album, indexPath: indexPath)
        //pageViewController.setup(album: album, indexPath: indexPath)

        present(pageViewController, animated: true, completion: nil)
        
//        let pageViewController = PageViewController2()
//        pageViewController.setup(images: images, startImage: startImage)
//
//        let mediaBrowser = MediaBrowserViewController(dataSource: pageViewController)
//       mediaBrowser.shouldShowPageControl = false
////        mediaBrowser.index = 5
//        
//        present(mediaBrowser, animated: true, completion: nil)
    }
}

