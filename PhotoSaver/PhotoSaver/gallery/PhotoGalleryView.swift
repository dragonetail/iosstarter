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

    internal lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()

        let columnCount: CGFloat = 4
        let cellSpacing: CGFloat = 2
        let size = (UIScreen.main.bounds.width - 2 - (columnCount - 1) * cellSpacing) / columnCount

        layout.itemSize = CGSize(width: size, height: size)
//         layout.itemSize = CGSize(width: 150, height: 150)
        layout.minimumInteritemSpacing = 2
        layout.minimumLineSpacing = 2
        layout.headerReferenceSize = CGSize(width: UIScreen.main.bounds.width, height: 30)
        layout.footerReferenceSize = CGSize(width: UIScreen.main.bounds.width, height: 5)
        layout.sectionInset = UIEdgeInsets(top: 10, left: 1, bottom: 10, right: 1)

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.white


        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(ImageCell.self, forCellWithReuseIdentifier: String(describing: ImageCell.self))
        collectionView.register(HeaderCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: String(describing: HeaderCell.self))
        collectionView.register(HeaderCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: String(describing: HeaderCell.self))

        return collectionView
    }()

    private lazy var emptyView: UIView = {
        let view = EmptyView()
        view.isHidden = true

        return view
    }()

    // 数据
    private var album: Album = Album()
    //    private var images: [Image] = []

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
        emptyView.autoCenterInSuperview()

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
        //        images = album.items
        self.album = album

        arrowButton.updateText(album.title)
        collectionView.reloadData()
        collectionView.g_scrollToTop()
        emptyView.isHidden = !album.sections.isEmpty

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


extension PhotoGalleryView: UICollectionViewDataSource {
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.album.sections.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return album.sections[section].images.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: ImageCell.self), for: indexPath) as! ImageCell
        let image = album.getImage(indexPath)
        //let image = section.images[indexPath.row]
        //let image = images[(indexPath as NSIndexPath).item]

        cell.configure(image)

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        print(kind)
        print(UICollectionView.elementKindSectionHeader)
        print(UICollectionView.elementKindSectionFooter)
//        if kind == UICollectionView.elementKindSectionHeader {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier:
            String(describing: HeaderCell.self), for: indexPath) as! HeaderCell

        header.configure("Test")
        return header
//        }
//        return UICollectionReusableView()
    }
}

extension PhotoGalleryView: UICollectionViewDelegateFlowLayout {
    // MARK: - UICollectionViewDelegateFlowLayout

//    static let columnCount: CGFloat = 4
//    static let cellSpacing: CGFloat = 2
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//
//        let size = (collectionView.bounds.size.width - (PhotoGalleryView.columnCount - 1) * PhotoGalleryView.cellSpacing) / PhotoGalleryView.columnCount
//        return CGSize(width: size, height: size)
//    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //let image = images[(indexPath as NSIndexPath).item]
        let image = album.getImage(indexPath)
        image.isSelected = !image.isSelected

        eventBus.triggerPageShowImages(album: album, indexPath: indexPath)
    }

    func configureFrameViews() {
        for case let cell as ImageCell in collectionView.visibleCells {
            cell.reconfigure()
        }
    }


//   func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets{
//        return UIEdgeInsets.init(top: 10, left: 0, bottom: 10, right: 0)
//    }
//
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize{
//        return CGSize(width: collectionView.bounds.size.width, height: 30)
//    }
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize{
//        return CGSize(width: collectionView.bounds.size.width, height: 5)
//    }


}


