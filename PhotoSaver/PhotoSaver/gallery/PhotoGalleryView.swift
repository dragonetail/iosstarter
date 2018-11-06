import UIKit
import Photos
import PureLayout


protocol PhotoGalleryViewDataSource: class {
    func numberOfSections(_ photoGalleryView: PhotoGalleryView) -> Int
    func titleOfSctions(_ photoGalleryView: PhotoGalleryView, indexPath: IndexPath) -> String
    func numberInSctions(_ photoGalleryView: PhotoGalleryView, section: Int) -> Int
    func image(_ photoGalleryView: PhotoGalleryView, indexPath: IndexPath) -> Image
}
protocol PhotoGalleryViewDelegate: class {
    func didSelectImage(_ photoGalleryView: PhotoGalleryView, indexPath: IndexPath)
}

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

    internal lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()

        let columnCount: CGFloat = 3
        let cellSpacing: CGFloat = 1
        let size = (UIScreen.main.bounds.width - 2 - (columnCount - 1) * cellSpacing) / columnCount

        layout.itemSize = CGSize(width: size, height: size)
        //         layout.itemSize = CGSize(width: 150, height: 150)
        layout.minimumInteritemSpacing = 1
        layout.minimumLineSpacing = 1
        layout.headerReferenceSize = CGSize(width: UIScreen.main.bounds.width, height: 40)
        //layout.footerReferenceSize = CGSize(width: UIScreen.main.bounds.width, height: 5)
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.white


        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(ImageCell.self, forCellWithReuseIdentifier: String(describing: ImageCell.self))
        collectionView.register(HeaderCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: String(describing: HeaderCell.self))
        //collectionView.register(HeaderCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: String(describing: HeaderCell.self))

        return collectionView
    }()

    private lazy var emptyView: UIView = {
        let view = EmptyView()
        view.isHidden = true

        return view
    }()


    private weak var dataSource: PhotoGalleryViewDataSource?
    private weak var delegate: PhotoGalleryViewDelegate?
    private weak var albumListButton: AlbumListButton?
    // 初始化

    convenience init(dataSource: PhotoGalleryViewDataSource, delegate: PhotoGalleryViewDelegate?, albumListButton: AlbumListButton?) {
        self.init(frame: .zero)

        self.dataSource = dataSource
        self.delegate = delegate

        self.albumListButton = albumListButton
        if let albumListButton = albumListButton {
            topView.addSubview(albumListButton)
        }
    }

    private override init(frame: CGRect) {
        super.init(frame: frame)

        [collectionView, topView, emptyView, loadingIndicatorView].forEach {
            addSubview($0)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        loadingIndicatorView.autoCenterInSuperview()
        emptyView.autoCenterInSuperview()

        topView.autoSetDimension(.height, toSize: 40)
        topView.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .bottom)

        albumListButton?.autoSetDimension(.height, toSize: 40)
        albumListButton?.autoCenterInSuperview()
        albumListButton?.layoutSubviews()

        collectionView.autoPinEdgesToSuperviewSafeArea(with: .zero, excludingEdge: .top)
        collectionView.autoPinEdge(.top, to: .bottom, of: topView, withOffset: 0.0)
    }

    internal func insertAlbumListControllerView(_ albumListControllerView: UIView) -> (expandedTopConstraint: NSLayoutConstraint, collapsedTopConstraint: NSLayoutConstraint) {

        insertSubview(albumListControllerView, belowSubview: loadingIndicatorView)

        albumListControllerView.autoPinEdgesToSuperviewSafeArea(with: .zero, excludingEdge: .top)
        let expandedTopConstraint = albumListControllerView.autoPinEdge(.top, to: .bottom, of: topView, withOffset: 0.0)
        expandedTopConstraint.isActive = false
        let collapsedTopConstraint = albumListControllerView.autoPinEdge(.top, to: .bottom, of: albumListControllerView)
        collapsedTopConstraint.isActive = true

        return (expandedTopConstraint: expandedTopConstraint, collapsedTopConstraint: collapsedTopConstraint)
    }


    internal func stopLoadingIndicatorView() {
        loadingIndicatorView.stopAnimating()
    }

    internal func updateView() {
        loadingIndicatorView.startAnimating()

        let numberOfSections = self.dataSource!.numberOfSections(self)
        emptyView.isHidden = (numberOfSections > 0)

        collectionView.reloadData()
        collectionView._scrollToTop()

        loadingIndicatorView.stopAnimating()
    }
}


extension PhotoGalleryView: UICollectionViewDataSource {
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.dataSource!.numberOfSections(self)
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataSource!.numberInSctions(self, section: section)
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: ImageCell.self), for: indexPath) as! ImageCell
        let image = self.dataSource!.image(self, indexPath: indexPath)

        cell.configure(image)

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            //print("HEADER DETECTED");//CALLED
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier:
                String(describing: HeaderCell.self), for: indexPath) as! HeaderCell
            
            header.configure(self.dataSource!.titleOfSctions(self, indexPath: indexPath))
            return header
        case UICollectionView.elementKindSectionFooter:
            print("FOOTER DETECTED");//NEVER CALLED
            break;
        default:
            print("DEFAULT DETECTED");//NEVER CALLED
            break;
        }
        
        return UICollectionReusableView();
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
        self.delegate?.didSelectImage(self, indexPath: indexPath)
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


