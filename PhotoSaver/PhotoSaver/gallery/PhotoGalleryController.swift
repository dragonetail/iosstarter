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
    
     var viewerController: ViewerController?
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

        
         let collectionView = self.photoGalleryView.collectionView
        
        self.viewerController = ViewerController(initialIndexPath: indexPath, collectionView: collectionView)
        self.viewerController!.dataSource = self
        self.viewerController!.delegate = self
        
//        #if os(iOS)
//        let headerView = HeaderView()
//        headerView.viewDelegate = self
//        self.viewerController?.headerView = headerView
//        let footerView = FooterView()
//        footerView.viewDelegate = self
//        self.viewerController?.footerView = footerView
//        #endif
        
        self.present(self.viewerController!, animated: false, completion: nil)

    }
}


extension PhotoGalleryController: ViewerControllerDataSource {
    
    func numberOfItemsInViewerController(_: ViewerController) -> Int {
        return album!.count
    }
    
    func viewerController(_: ViewerController, viewableAt indexPath: IndexPath) -> Viewable {
         let image = album!.getImage(indexPath)
//        let viewable = self.photo(at: indexPath)
//        if let cell = self.collectionView?.cellForItem(at: indexPath) as? PhotoCell, let placeholder = cell.imageView.image {
//            viewable.placeholder = placeholder
//        }
        
        return image
    }
}

extension PhotoGalleryController: ViewerControllerDelegate {
    func viewerController(_: ViewerController, didChangeFocusTo _: IndexPath) {}
    
    func viewerControllerDidDismiss(_: ViewerController) {
        #if os(tvOS)
        // Used to refocus after swiping a few items in fullscreen.
        self.setNeedsFocusUpdate()
        self.updateFocusIfNeeded()
        #endif
    }
    
    func viewerController(_: ViewerController, didFailDisplayingViewableAt _: IndexPath, error _: NSError) {
        
    }
    
    func viewerController(_ viewerController: ViewerController, didLongPressViewableAt indexPath: IndexPath) {
        print("didLongPressViewableAt: \(indexPath)")
    }
}



