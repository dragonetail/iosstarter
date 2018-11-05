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
        
//        let pageViewController = PageViewController(album: album, indexPath: indexPath)
//        //pageViewController.setup(album: album, indexPath: indexPath)
//
//        present(pageViewController, animated: true, completion: nil)
//
//        let pageViewController = PageViewController2()
//        pageViewController.setup(images: images, startImage: startImage)
//
//        let mediaBrowser = MediaBrowserViewController(dataSource: pageViewController)
//       mediaBrowser.shouldShowPageControl = false
////        mediaBrowser.index = 5
//        
//        present(mediaBrowser, animated: true, completion: nil)

        
        self.imageViewController = ImageViewController()
        self.imageViewController.album = self.album
        self.imageViewController.initialIndexPath = IndexPath(row: indexPath.row, section: indexPath.section + 1)
        let imageViewHeader = ImageViewHeader()
        imageViewHeader.viewDelegate = self
        self.imageViewController.imageViewHeader = imageViewHeader
//        #if os(iOS)
//        let headerView = HeaderView()
//        headerView.viewDelegate = self
//        self.viewerController?.headerView = headerView
//        let footerView = FooterView()
//        footerView.viewDelegate = self
//        self.viewerController?.footerView = footerView
//        #endif
        
        self.present(self.imageViewController!, animated: false, completion: nil)

    }
}

extension PhotoGalleryController: ImageViewHeaderDelegate {
    
    func headerView(_: ImageViewHeader, didPressClearButton _: UIButton) {
        self.imageViewController?.dismiss(animated: true)
    }
    
    func headerView(_: ImageViewHeader, didPressMenuButton button: UIButton) {
//        let rect = CGRect(x: 0, y: 0, width: 50, height: 50)
//        self.optionsController = OptionsController(sourceView: button, sourceRect: rect)
//        self.optionsController!.delegate = self
//        self.viewerController?.present(self.optionsController!, animated: true, completion: nil)
    }
}


