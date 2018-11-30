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
        let photoGalleryView = PhotoGalleryView(dataSource: self, delegate: self, albumListButton: albumListButton)

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
        self.photoGalleryView.updateView()
        toggaleAlbumControllerView()
    }
}


extension PhotoGalleryController: PhotoGalleryViewDataSource {
    func numberOfSections(_ photoGalleryView: PhotoGalleryView) -> Int {
        return self.album?.sections.count ?? 0
    }
    func section(_ photoGalleryView: PhotoGalleryView, section: Int) -> ImageSection {
        return album!.sections[section]
    }
    func image(_ photoGalleryView: PhotoGalleryView, indexPath: IndexPath) -> Image {
        return album!.getImage(indexPath)
    }
}

extension PhotoGalleryController: PhotoGalleryViewDelegate {
    func didSelectImage(_ photoGalleryView: PhotoGalleryView, indexPath: IndexPath) {

        let imageViewController = ImageViewController(album: album!, initialIndexPath: indexPath)

        self.present(imageViewController, animated: false, completion: nil)
    }
}

