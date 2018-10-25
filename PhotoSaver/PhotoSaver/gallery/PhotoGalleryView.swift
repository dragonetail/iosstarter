import UIKit
import Photos
import PureLayout

class PhotoGalleryView: UIView {
    //控件
    private lazy var loadingIndicatorView: UIActivityIndicatorView = {
        let loadingIndicatorView: UIActivityIndicatorView = UIActivityIndicatorView(style: .whiteLarge)
        loadingIndicatorView.color = .gray
        loadingIndicatorView.isHidden = false
        loadingIndicatorView.hidesWhenStopped = true
        //loadingIndicatorView.g_addRoundBorder()
        //loadingIndicatorView.g_addShadow()

        return loadingIndicatorView
    }()

    private lazy var topView: UIView = {
        let topView = UIView()
        topView.backgroundColor = UIColor.white

        return topView
    }()

    private lazy var arrowButton: ArrowButton = {
        let arrowButton = ArrowButton()
        arrowButton.layoutSubviews()

        arrowButton.addTarget(self, action: #selector(arrowButtonTapped(_:)), for: .touchUpInside)

        return arrowButton
    }()

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 2
        layout.minimumLineSpacing = 2

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.white


        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(ImageCell.self, forCellWithReuseIdentifier: String(describing: ImageCell.self))

        return collectionView
    }()

    private lazy var emptyView: UIView = {
        let view = EmptyView()
        view.isHidden = true

        return view
    }()

    // 数据
    private var selectedAlbum: Album?
    private var images: [Image] = []

    // 初始化
    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubviews()
        setupConstraints()

        //loadingIndicatorView.startAnimating()
        eventBus.bindSelectAlbum(selectAlbum)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    // MARK: - Setup
    private func addSubviews() {
        [collectionView, topView, emptyView, loadingIndicatorView].forEach {
            addSubview($0)
        }

        [arrowButton].forEach {
            topView.addSubview($0)
        }
    }

    private func setupConstraints() {
        loadingIndicatorView.autoCenterInSuperview()

        topView.autoSetDimension(.height, toSize: 40)
        topView.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .bottom)

        arrowButton.autoSetDimension(.height, toSize: 40)
        arrowButton.autoCenterInSuperview()
        arrowButton.updateText("Blank Title")

        collectionView.autoPinEdgesToSuperviewSafeArea(with: .zero, excludingEdge: .top)
        collectionView.autoPinEdge(.top, to: .bottom, of: topView, withOffset: 0.0)
    }

    private var albumListController: AlbumListController?
    internal func insertAlbumListControllerView(_ albumListController: AlbumListController) {
        self.albumListController = albumListController

        let albumListControllerView = albumListController.view!
        insertSubview(albumListControllerView, belowSubview: topView)

        albumListControllerView.autoPinEdgesToSuperviewSafeArea(with: .zero, excludingEdge: .top)
        albumListController.expandedTopConstraint = albumListControllerView.autoPinEdge(.top, to: .bottom, of: topView, withOffset: 0.0)
        albumListController.expandedTopConstraint?.isActive = false
        albumListController.collapsedTopConstraint = albumListControllerView.autoPinEdge(.top, to: .bottom, of: albumListControllerView)
    }


    internal func stopLoadingIndicatorView() {
        loadingIndicatorView.stopAnimating()
    }

    private func selectAlbum(_ album: Album) {
        images = album.items
        selectedAlbum = album

        arrowButton.updateText(album.collection.localizedTitle ?? "-")
        collectionView.reloadData()
        collectionView.g_scrollToTop()
        emptyView.isHidden = !album.items.isEmpty

        toggaleAlbumControllerView()
    }



    @objc func arrowButtonTapped(_ button: ArrowButton) {
        toggaleAlbumControllerView()
    }

    func toggaleAlbumControllerView() {
        albumListController!.toggle()
        arrowButton.toggle(albumListController!.expanding)
    }
}


extension PhotoGalleryView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    // MARK: - UICollectionViewDataSource

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: ImageCell.self), for: indexPath)
        as! ImageCell
        let image = images[(indexPath as NSIndexPath).item]

        cell.configure(image)

        return cell
    }

    // MARK: - UICollectionViewDelegateFlowLayout

    static let columnCount: CGFloat = 4
    static let cellSpacing: CGFloat = 2
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let size = (collectionView.bounds.size.width - (PhotoGalleryView.columnCount - 1) * PhotoGalleryView.cellSpacing)
        / PhotoGalleryView.columnCount
        return CGSize(width: size, height: size)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let image = images[(indexPath as NSIndexPath).item]
        image.isSelected = !image.isSelected

        eventBus.triggerPageShowImages(images: images, startImage: image)
    }

    func configureFrameViews() {
        for case let cell as ImageCell in collectionView.visibleCells {
            cell.reconfigure()
        }
    }
}


